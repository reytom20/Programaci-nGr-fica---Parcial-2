using UnityEngine;


// Cuando la camara baja del nivel del agua se activa el tinte azul y la niebla por profundidad.
[RequireComponent(typeof(Camera))]
public class PostProcessAgua : MonoBehaviour
{
    [Header("Shader de Amplify")]
    [SerializeField] Shader shaderAgua;

    [Header("Nivel del agua")]
    [Tooltip("Superficie del agua: se usa su altura (Y) como nivel del agua")]
    [SerializeField] Transform agua;
    [Tooltip("Velocidad con la que entra/sale el efecto al cruzar la superficie")]
    [SerializeField] float velocidadTransicion = 4f;

    [Header("Tinte")]
    public Color colorTinte = new Color(0.15f, 0.55f, 0.8f, 1f);
    [Range(0f, 1f)] public float cantidadTinte = 0.6f;

    [Header("Niebla por profundidad (depth fade)")]
    public Color colorNiebla = new Color(0.02f, 0.18f, 0.3f, 1f);
    [Range(0f, 50f)] public float inicioNiebla = 1f;
    [Range(0.1f, 100f)] public float distanciaNiebla = 25f;
    [Range(0f, 1f)] public float densidadNiebla = 0.95f;

    [Header("Material (creado en Awake)")]
    public Material matAgua;

    float bajoElAgua;   // 0 = fuera del agua, 1 = bajo el agua

    public bool EstaBajoElAgua => agua != null && transform.position.y < agua.position.y;

    void Awake()
    {
        matAgua = new Material(shaderAgua);

        // La niebla necesita la profundidad de la escena (_CameraDepthTexture).
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.Depth;
    }

    void Update()
    {
        float objetivo = EstaBajoElAgua ? 1f : 0f;
        bajoElAgua = Mathf.MoveTowards(bajoElAgua, objetivo, velocidadTransicion * Time.deltaTime);

        // Todas las variables se pueden modificar en runtime desde el Inspector.
        matAgua.SetFloat("_Underwater", bajoElAgua);
        matAgua.SetColor("_TintColor", colorTinte);
        matAgua.SetFloat("_TintAmount", cantidadTinte);
        matAgua.SetColor("_FogColor", colorNiebla);
        matAgua.SetFloat("_FogStart", inicioNiebla);
        matAgua.SetFloat("_FogDistance", distanciaNiebla);
        matAgua.SetFloat("_FogDensity", densidadNiebla);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // Fuera del agua no hace falta procesar nada
        if (bajoElAgua <= 0f)
        {
            Graphics.Blit(source, destination);
            return;
        }

        Graphics.Blit(source, destination, matAgua);
    }

    void OnDestroy()
    {
        Destroy(matAgua);
    }
}
