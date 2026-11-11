using UnityEngine;

// Post-proceso de la camara (como en clase):
// OnRenderImage lee la imagen que iba a mostrar la camara (source),
// le aplica los materiales activos y escribe el resultado en destination.
[RequireComponent(typeof(Camera))]
public class PostProcess : MonoBehaviour
{
    [Header("Shaders de Amplify")]
    [SerializeField] Shader shaderParpadeo;
    [SerializeField] Shader shaderFlashbang;
    [SerializeField] Shader shaderCamara;

    [Header("Efectos activos")]
    public bool parpadeo;
    public bool flashbang;
    public bool camara;

    [Header("Materiales")]
    public Material matParpadeo;
    public Material matFlashbang;
    public Material matCamara;

    RenderTexture fantasma;

    void Awake()
    {
        matParpadeo = new Material(shaderParpadeo);
        matFlashbang = new Material(shaderFlashbang);
        matCamara = new Material(shaderCamara);
    }

    // Saca una "foto" de lo que ve la camara y la usa como imagen fantasma del flashbang.
    public void CapturarFantasma()
    {
        if (fantasma == null) fantasma = new RenderTexture(Screen.width, Screen.height, 24);

        Camera cam = GetComponent<Camera>();
        cam.targetTexture = fantasma;
        cam.Render();
        cam.targetTexture = null;

        matFlashbang.SetTexture("_GhostTex", fantasma);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        RenderTexture actual = source;

        if (camara) actual = Aplicar(actual, source, matCamara);
        if (flashbang) actual = Aplicar(actual, source, matFlashbang);
        if (parpadeo) actual = Aplicar(actual, source, matParpadeo);

        Graphics.Blit(actual, destination);
        if (actual != source) RenderTexture.ReleaseTemporary(actual);
    }

    // Aplica un material en una RenderTexture temporal y libera la anterior.
    RenderTexture Aplicar(RenderTexture entrada, RenderTexture source, Material mat)
    {
        RenderTexture salida = RenderTexture.GetTemporary(entrada.width, entrada.height);
        Graphics.Blit(entrada, salida, mat);
        if (entrada != source) RenderTexture.ReleaseTemporary(entrada);
        return salida;
    }

    void OnDestroy()
    {
        Destroy(matParpadeo);
        Destroy(matFlashbang);
        Destroy(matCamara);
        if (fantasma != null) fantasma.Release();
    }
}
