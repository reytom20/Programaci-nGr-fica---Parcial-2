
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[RequireComponent(typeof(Image))]
public class WaterInteractionController : MonoBehaviour
{

    [Header("Referencias")]
    [SerializeField] private Image waterImage;

    private RectTransform waterRect;

    private readonly Vector3[] waterCorners = new Vector3[4];

    [Header("Configuración")]
    [SerializeField, Range(0f, 1f)]
    private float splashThreshold = 0.8f;

    private readonly List<WaterInteractable> interactables = new(); //Objetos registrados que pueden interactuar con el agua
    private readonly Dictionary<WaterInteractable, float> previousImmersions = new(); //guarda la inmersión anterior de cada objeto para detectar entradas y salidas
    private readonly HashSet<WaterInteractable> initializedInteractables = new(); //objetos ya inicializados para evitar efectos falsos al registrarlos

    private Material waterMaterial;

    private static readonly int SinkingProgressID = Shader.PropertyToID("_SinkingProgress");

    private static readonly int ImpactPositionID = Shader.PropertyToID("_ImpactPosition");

    private static readonly int SplashPositionID = Shader.PropertyToID("_SplashPosition");

    private static readonly int SplashProgressID = Shader.PropertyToID("_SplashProgress");

    private static readonly int SplashActiveID = Shader.PropertyToID("_SplashActive");

    private static readonly int ExitPositionID = Shader.PropertyToID("_ExitPosition");

    private static readonly int ExitProgressID = Shader.PropertyToID("_ExitProgress");

    [Header("Animación del agua")]
    [SerializeField] private float sinkingSpeed = 1.6f;
    [SerializeField] private float recoverySpeed = 0.6f;

    private float currentSinkingProgress;
    private bool isRecovering;
    //objeto que actualmente controla la deformación de hundimiento
    private WaterInteractable activeSinkingObject;

    [Header("Splash")]
    [SerializeField] private float splashDuration = 1.2f;

    private float splashTimer; //tiempo desde que empezó el splash
    private bool isSplashPlaying;

    [Header("Exit Water")]
    [SerializeField] private float exitRecoverySpeed = 0.8f; //velocidad con la que desaparece el estiramiento

    private float currentExitProgress;

    private void Awake()
    {
        if (waterImage == null)
            waterImage = GetComponent<Image>();


        waterRect = waterImage.rectTransform;

        waterMaterial = waterImage.material;

        waterMaterial.SetFloat(SplashActiveID, 0f);
        waterMaterial.SetFloat(SplashProgressID, 0f);
        waterMaterial.SetFloat(ExitProgressID, 0f);
    }

    public void RegisterInteractable(WaterInteractable interactable)
    {
        if (interactable == null || interactables.Contains(interactable))
            return;

        interactables.Add(interactable);
        previousImmersions[interactable] = 0f;
    }

    // Elimina el objeto y limpia su historial de inmersión.
    public void UnregisterInteractable(WaterInteractable interactable)
    {
        interactables.Remove(interactable);
        initializedInteractables.Remove(interactable);
        previousImmersions.Remove(interactable);

        if (activeSinkingObject == interactable)
        {
            activeSinkingObject = null;
            isRecovering = false;
            currentSinkingProgress = 0f;

            waterMaterial.SetFloat(SinkingProgressID, 0f);
        }
    }

    private void Update()
    {
        foreach (WaterInteractable interactable in interactables)
        {
            CheckImmersion(interactable);
        }

        UpdateSplash();
        UpdateExit();
    }

    private void CheckImmersion(WaterInteractable interactable)
    {
        RectTransform objectRect = interactable.RectTransform;

        Vector3[] corners = new Vector3[4];
        objectRect.GetWorldCorners(corners);

        float bottomY = Mathf.Min(
            corners[0].y,
            corners[1].y,
            corners[2].y,
            corners[3].y
        );

        float topY = Mathf.Max(
            corners[0].y,
            corners[1].y,
            corners[2].y,
            corners[3].y
        );

        float surfaceY = GetWaterSurfaceY();

        float objectHeight = topY - bottomY;

        if (objectHeight <= 0f)
            return;

        float submergedHeight = surfaceY - bottomY;

        //calcula qué porcentaje del objeto está sumergido
        float immersion = Mathf.Clamp01(
            submergedHeight / objectHeight
        );

        //guarda el estado inicial para evitar efectos al comenzar
        if (initializedInteractables.Add(interactable))
        {
            previousImmersions[interactable] = immersion;
            return;
        }

        Vector3 objectCenter = (corners[0] + corners[2]) * 0.5f;

        Vector3 localPosition = waterRect.InverseTransformPoint(objectCenter); //convertir la posición del centro del objeto desde coordenadas de mundo a coordenadas locales del agua

        //convierte la posición horizontal del objeto a coordenadas UV
        float impactX = Mathf.InverseLerp(
            waterRect.rect.xMin,
            waterRect.rect.xMax,
            localPosition.x
        );

        float previousImmersion = previousImmersions[interactable];
        bool completelyExitedWater = previousImmersion > 0f && immersion <= 0f;
        bool isExitingWater = immersion < previousImmersion && immersion > 0f;  //detecta si el objeto está saliendo, pero sigue parcialmente sumergido

        bool crossedSplashThreshold = previousImmersion < splashThreshold && immersion >= splashThreshold; //Detecta cuándo el objeto alcanza el umbral para generar el splash

        if (crossedSplashThreshold)
        {
            StartSplash(impactX);
        }

        if (completelyExitedWater)
        {
            StartSplash(impactX);
        }

        if (isExitingWater)
        {
            currentExitProgress = Mathf.Clamp01(1f - immersion);

            //solamente actualizamos la posicion de salida del objeto que este saliendo
            waterMaterial.SetFloat(ExitPositionID, impactX);
        }

        previousImmersions[interactable] = immersion;

        if (crossedSplashThreshold)
        {
            isRecovering = true;
        }

        //asigna el control del hundimiento al objeto que comienza a entrar
        if (activeSinkingObject == null &&
            immersion > previousImmersion &&
            immersion > 0f)
        {
            activeSinkingObject = interactable;
        }

        //solo el objeto activo puede modificar el hundimiento
        if (activeSinkingObject != interactable)
            return;

        if (isRecovering)
        {
            currentSinkingProgress = Mathf.MoveTowards(
                currentSinkingProgress,
                0f,
                recoverySpeed * Time.deltaTime
            );
        }
        else
        {
            float progress = Mathf.Clamp01(
                immersion / splashThreshold
            );

            float targetSinkingProgress = Mathf.SmoothStep(
                0f,
                1f,
                progress
            );

            currentSinkingProgress = Mathf.MoveTowards(
                currentSinkingProgress,
                targetSinkingProgress,
                sinkingSpeed * Time.deltaTime
            );
        }

        //libera el objeto cuando finaliza la recuperación del hundimiento
        if (isRecovering && currentSinkingProgress <= 0f)
        {
            isRecovering = false;
            activeSinkingObject = null;
        }

        //libera el objeto si sale del agua antes de activar el splash
        if (immersion <= 0f && currentSinkingProgress <= 0f)
        {
            activeSinkingObject = null;
            isRecovering = false;
        }

        waterMaterial.SetFloat(ImpactPositionID, impactX);
        waterMaterial.SetFloat(SinkingProgressID, currentSinkingProgress);
        Debug.Log("SinkingProgress: " + currentSinkingProgress);
    }

    //para que comience el splash desde el punto de contacto con el objeto
    private void StartSplash(float impactX)
    {
        isSplashPlaying = true;
        splashTimer = 0f;

        waterMaterial.SetFloat(SplashPositionID, impactX);
        waterMaterial.SetFloat(SplashProgressID, 0f);
        waterMaterial.SetFloat(SplashActiveID, 1f);
    }

    //anima la expansión de las ondas y las desactiva al finalizar
    private void UpdateSplash()
    {
        if (!isSplashPlaying)
            return;

        splashTimer += Time.deltaTime;

        float progress = Mathf.Clamp01(
            splashTimer / splashDuration
        );

        waterMaterial.SetFloat(SplashProgressID, progress);

        if (progress >= 1f)
        {
            isSplashPlaying = false;
            waterMaterial.SetFloat(SplashActiveID, 0f);
        }
    }

    //devuelve gradualmente la elevación a su estado normal
    private void UpdateExit()
    {
        currentExitProgress = Mathf.MoveTowards(
            currentExitProgress,
            0f,
            exitRecoverySpeed * Time.deltaTime
        );

        waterMaterial.SetFloat(ExitProgressID, currentExitProgress);
    }

    //obtener la altura del agua a partir de WaterLevel
    private float GetWaterSurfaceY()
    {
        waterRect.GetWorldCorners(waterCorners);

        float bottomY = waterCorners[0].y;
        float topY = waterCorners[1].y;

        float waterLevel = waterImage.material.GetFloat("_WaterLevel");

        return Mathf.Lerp(bottomY, topY, waterLevel);
    }

}
