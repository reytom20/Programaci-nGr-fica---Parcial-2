using System.Collections;
using UnityEngine;

// saca la foto a una RenderTexture creada en runtime
// y hace el efecto de obturador + flash con post-proceso (OnRenderImage).
[RequireComponent(typeof(Camera))]
public class CamaraFoto : MonoBehaviour
{
    [SerializeField] Shader shaderFlash;
    [SerializeField] float duracionObturador = 0.1f;
    [SerializeField] float duracionFlash = 0.4f;

    [Header("Material (se crea en Awake, se edita en Play)")]
    public Material matFlash;

    public RenderTexture Foto { get; private set; }
    bool capturar;

    void Awake()
    {
        matFlash = new Material(shaderFlash);

        // RT que solo vive en runtime, del tamanio de la pantalla.
        Foto = new RenderTexture(Screen.width, Screen.height, 0);
        Foto.Create();
    }

    // Pide la foto: se copia en el proximo OnRenderImage, cuando el frame
    // ya tiene todo dibujado (objetos + binoculares). Espera hasta que se copie.
    public IEnumerator SacarFoto()
    {
        capturar = true;
        while (capturar) yield return null;
    }

    // El obturador se cierra, explota el flash y la imagen vuelve.
    public IEnumerator Flash()
    {
        for (float t = 0f; t < duracionObturador; t += Time.deltaTime)
        {
            matFlash.SetFloat("_Shutter", t / duracionObturador);
            yield return null;
        }
        for (float t = 0f; t < duracionFlash; t += Time.deltaTime)
        {
            float k = 1f - t / duracionFlash;
            matFlash.SetFloat("_Shutter", k);
            matFlash.SetFloat("_Flash", k);
            yield return null;
        }
        matFlash.SetFloat("_Shutter", 0f);
        matFlash.SetFloat("_Flash", 0f);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // source es lo que vio la camara este frame: si hay que sacar la foto, se copia a la RT.
        if (capturar)
        {
            Graphics.Blit(source, Foto);
            capturar = false;
        }
        Graphics.Blit(source, destination, matFlash);
    }

    void OnDestroy()
    {
        // Si no se libera, la RT queda viva en memoria.
        Foto.Release();
        Destroy(Foto);
        Destroy(matFlash);
    }
}
