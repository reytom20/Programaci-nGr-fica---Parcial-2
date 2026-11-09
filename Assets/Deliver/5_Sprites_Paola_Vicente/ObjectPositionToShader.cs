
using UnityEngine;
using UnityEngine.UI;

public class ObjectPositionToShader : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] private Image waterImage;
    [SerializeField] private RectTransform targetObject;

    private Material waterMaterial;
    private Material originalMaterial;

    private static readonly int ObjectPositionID =
        Shader.PropertyToID("_ImpactObjectPosition");

    [Header("Detección de superficie")]
    [SerializeField] private float waterLevel = 0.7f;
    [SerializeField] private float waveFrequency = 20f;
    [SerializeField] private float waveSpeed = 2f;
    [SerializeField] private float waveAmplitude = 0.03f;

    [Header("Espuma de impacto")]
    [SerializeField] private float foamDuration = 1.5f;

    private float lastImpactTime = -100f;

    private bool wasUnderwater;

    private void Awake()
    {
        // Guardamos el material original.
        originalMaterial = waterImage.material;

        // Creamos una instancia independiente.
        waterMaterial = new Material(originalMaterial);
        waterImage.material = waterMaterial;
    }

    private void Start()
    {
        wasUnderwater = IsUnderwater();
    }

    private void Update()
    {
        // Obtenemos la posición del cubo.
        Vector3 objectPosition = targetObject.position;

        Vector4 position = new Vector4(
            objectPosition.x,
            objectPosition.y,
            objectPosition.z,
            1f
        );

        // Actualizamos nuestra instancia del material.
        waterMaterial.SetVector(ObjectPositionID, position);

        // Obtenemos el material del CanvasRenderer.
        Material renderedMaterial =
            waterImage.canvasRenderer.GetMaterial();

        // Actualizamos el material renderizado si corresponde.
        if (renderedMaterial != null &&
            renderedMaterial.HasProperty(ObjectPositionID))
        {
            renderedMaterial.SetVector(
                ObjectPositionID,
                position
            );
        }

        bool isUnderwater = IsUnderwater();

        if (isUnderwater != wasUnderwater)
        {
            if (isUnderwater)
            {
                Debug.Log("ENTRÓ AL AGUA");
            }
            else
            {
                Debug.Log("SALIÓ DEL AGUA");
            }

            GenerateImpact();

            wasUnderwater = isUnderwater;
        }

        UpdateFoam();
    }

    private float GetWaterSurfaceHeight(float normalizedX)
    {
        float wave = Mathf.Sin(
            normalizedX * waveFrequency +
            Time.time * waveSpeed
        ) * waveAmplitude;

        return waterLevel + wave;
    }


    private Vector2 GetObjectUV()
    {
        // Convertimos la posición del cubo al espacio local del agua.
        Vector3 localPosition =
            waterImage.rectTransform.InverseTransformPoint(
                targetObject.position
            );

        // Obtenemos las dimensiones del RectTransform del agua.
        Rect waterRect = waterImage.rectTransform.rect;

        // Convertimos la posición local a coordenadas UV (0 a 1).
        float u = Mathf.InverseLerp(
            waterRect.xMin,
            waterRect.xMax,
            localPosition.x
        );

        float v = Mathf.InverseLerp(
            waterRect.yMin,
            waterRect.yMax,
            localPosition.y
        );

        return new Vector2(u, v);
    }


    private bool IsUnderwater()
    {
        Vector2 objectUV = GetObjectUV();

        // Si está fuera de los límites horizontales,
        // no consideramos que esté dentro del agua.
        if (objectUV.x < 0f || objectUV.x > 1f)
            return false;

        // Calculamos la altura de la ola en esa posición X.
        float surfaceHeight =
            GetWaterSurfaceHeight(objectUV.x);

        // Comparamos la altura del cubo con la superficie.
        return objectUV.y < surfaceHeight;
    }


    private void GenerateImpact()
    {
        lastImpactTime = Time.time;

        // Obtenemos la posición del cubo en UV.
        Vector2 objectUV = GetObjectUV();

        // Limitamos la posición horizontal al agua.
        float impactX = Mathf.Clamp01(objectUV.x);

        // Activamos la onda en el material.
        waterMaterial.SetFloat("_ImpactPosition", impactX);
        waterMaterial.SetFloat("_ImpactTime", Time.time);
        waterMaterial.SetFloat("_ImpactStrength", 0.008f);
        waterMaterial.SetFloat("_ImpactFoamStrength", 0f);

        // Actualizamos también el material renderizado.
        Material renderedMaterial =
            waterImage.canvasRenderer.GetMaterial();

        if (renderedMaterial != null)
        {
            renderedMaterial.SetFloat("_ImpactPosition", impactX);
            renderedMaterial.SetFloat("_ImpactTime", Time.time);
            renderedMaterial.SetFloat("_ImpactStrength", 0.008f);
            renderedMaterial.SetFloat("_ImpactFoamStrength", 0f);
        }
    }


    private void UpdateFoam()
    {
        float elapsedTime = Time.time - lastImpactTime;

        // La intensidad disminuye de 1 a 0.
        float foamStrength = Mathf.Clamp01(
            1f - elapsedTime / foamDuration
        );

        waterMaterial.SetFloat(
            "_ImpactFoamStrength",
            foamStrength
        );

        Material renderedMaterial =
            waterImage.canvasRenderer.GetMaterial();

        if (renderedMaterial != null &&
            renderedMaterial.HasProperty("_ImpactFoamStrength"))
        {
            renderedMaterial.SetFloat(
                "_ImpactFoamStrength",
                foamStrength
            );
        }
    }


    private void OnDestroy()
    {
        if (waterMaterial != null)
        {
            if (waterImage != null)
                waterImage.material = originalMaterial;

            Destroy(waterMaterial);
        }
    }
}
