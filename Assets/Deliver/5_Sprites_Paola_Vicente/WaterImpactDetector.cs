
using UnityEngine;
using UnityEngine.UI;

public class WaterImpactDetector : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private RectTransform waterRect;
    [SerializeField] private Image waterImage;

    [Header("Configuración del impacto")]
    [SerializeField] private float impactStrength = 0.03f;

    private RectTransform objectRect;
    private Material waterMaterial;
    private bool wasUnderwater;

    private void Awake()
    {
        objectRect = GetComponent<RectTransform>();

        // Instancia propia para no modificar el material original.
        waterMaterial = new Material(waterImage.material);
        waterImage.material = waterMaterial;
    }

    private void Start()
    {
        wasUnderwater = IsUnderwater();
    }

    private void Update()
    {
        bool isUnderwater = IsUnderwater();

        if (isUnderwater != wasUnderwater)
        {
            GenerateImpact();
            wasUnderwater = isUnderwater;
        }
    }

    private bool IsUnderwater()
    {
        Vector3[] corners = new Vector3[4];
        waterRect.GetWorldCorners(corners);

        float waterSurfaceY = corners[1].y;

        return objectRect.position.y < waterSurfaceY;
    }

    private void GenerateImpact()
    {
        Vector3 localPosition =
            waterRect.InverseTransformPoint(objectRect.position);

        float normalizedX = Mathf.InverseLerp(
            waterRect.rect.xMin,
            waterRect.rect.xMax,
            localPosition.x
        );

        waterMaterial.SetFloat("_ImpactPosition", normalizedX);
        waterMaterial.SetFloat("_ImpactTime", Time.time);
        waterMaterial.SetFloat("_ImpactStrength", impactStrength);
    }

    private void OnDestroy()
    {
        if (waterMaterial != null)
        {
            if (waterImage != null)
                waterImage.material = null;

            Destroy(waterMaterial);
        }
    }
}

