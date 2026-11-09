
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

    private Material waterMaterial;

    private static readonly int SinkingProgressID = Shader.PropertyToID("_SinkingProgress");

    private static readonly int ImpactPositionID = Shader.PropertyToID("_ImpactPosition");

    [Header("Animación del agua")]
    [SerializeField] private float sinkingSpeed = 1.2f;
    [SerializeField] private float recoverySpeed = 0.6f;

    private float currentSinkingProgress;
    private bool isRecovering;

    private void Awake()
    {
        if (waterImage == null)
            waterImage = GetComponent<Image>();


        waterRect = waterImage.rectTransform;

        waterMaterial = waterImage.material;

    }

    public void RegisterInteractable(WaterInteractable interactable)
    {
        if (interactable != null && !interactables.Contains(interactable))
            interactables.Add(interactable);
    }

    public void UnregisterInteractable(WaterInteractable interactable)
    {
        interactables.Remove(interactable);
    }


    private void Update()
    {
        foreach (WaterInteractable interactable in interactables)
        {
            CheckImmersion(interactable);
        }
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

