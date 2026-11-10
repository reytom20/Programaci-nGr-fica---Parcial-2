
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

    private readonly List<WaterInteractable> interactables = new();
    private readonly Dictionary<WaterInteractable, float> previousImmersions = new();

    private Material waterMaterial;

    private static readonly int SinkingProgressID = Shader.PropertyToID("_SinkingProgress");

    private static readonly int ImpactPositionID = Shader.PropertyToID("_ImpactPosition");

    private static readonly int SplashPositionID = Shader.PropertyToID("_SplashPosition");

    private static readonly int SplashProgressID = Shader.PropertyToID("_SplashProgress");

    private static readonly int SplashActiveID = Shader.PropertyToID("_SplashActive");

    [Header("Animación del agua")]
    [SerializeField] private float sinkingSpeed = 1.6f;
    [SerializeField] private float recoverySpeed = 0.6f;

    private float currentSinkingProgress;
    private bool isRecovering;

    [Header("Splash")]
    [SerializeField] private float splashDuration = 1.2f;

    private float splashTimer; //tiempo desde que empezó el splash
    private bool isSplashPlaying;

    private void Awake()
    {
        if (waterImage == null)
            waterImage = GetComponent<Image>();


        waterRect = waterImage.rectTransform;

        waterMaterial = waterImage.material;

        waterMaterial.SetFloat(SplashActiveID, 0f);
        waterMaterial.SetFloat(SplashProgressID, 0f);
    }

    public void RegisterInteractable(WaterInteractable interactable)
    {
        if (interactable == null || interactables.Contains(interactable))
            return;

        interactables.Add(interactable);
        previousImmersions[interactable] = 0f;
    }

    public void UnregisterInteractable(WaterInteractable interactable)
    {
        interactables.Remove(interactable);
        previousImmersions.Remove(interactable);
    }

    private void Update()
    {
        foreach (WaterInteractable interactable in interactables)
        {
            CheckImmersion(interactable);
        }

        UpdateSplash();
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

        float immersion = Mathf.Clamp01(
            submergedHeight / objectHeight
        );

        Vector3 objectCenter = interactable.RectTransform.position;

        Vector3 localPosition = waterRect.InverseTransformPoint(
            objectCenter
        );

        float impactX = Mathf.InverseLerp(
            waterRect.rect.xMin,
            waterRect.rect.xMax,
            localPosition.x
        );

        float previousImmersion = previousImmersions[interactable];

        bool crossedSplashThreshold =
            previousImmersion < splashThreshold &&
            immersion >= splashThreshold;

        if (crossedSplashThreshold)
        {
            StartSplash(impactX);
        }

        previousImmersions[interactable] = immersion;

        if (immersion >= splashThreshold)
        {
            isRecovering = true;
        }

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

        if (immersion <= 0f && currentSinkingProgress <= 0f)
        {
            isRecovering = false;
        }

        waterMaterial.SetFloat(ImpactPositionID, impactX);
        waterMaterial.SetFloat(SinkingProgressID, currentSinkingProgress);
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

    //obtener la altura del agua
    private float GetWaterSurfaceY()
    {
        waterRect.GetWorldCorners(waterCorners);

        float bottomY = waterCorners[0].y;
        float topY = waterCorners[1].y;

        float waterLevel = waterImage.material.GetFloat("_WaterLevel");

        return Mathf.Lerp(bottomY, topY, waterLevel);
    }

}

