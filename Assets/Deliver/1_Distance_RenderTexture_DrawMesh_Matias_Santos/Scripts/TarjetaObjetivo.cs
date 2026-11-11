using UnityEngine;
using UnityEngine.UI;

// Tarjeta con el objeto a buscar girando.
// Una camara deshabilitada lo renderiza a mano (Render()) en una RT creada en runtime.
public class TarjetaObjetivo : MonoBehaviour
{
    [SerializeField] Camera camaraPreview;     // deshabilitada, solo ve la capa del preview
    [SerializeField] Transform pivote;
    [SerializeField] MeshFilter meshFilter;
    [SerializeField] MeshRenderer meshRenderer;
    [SerializeField] RawImage imagen;
    [SerializeField] float tamanio = 1.8f;
    [SerializeField] float velocidadGiro = 45f;

    RenderTexture rt;
    MaterialPropertyBlock mpb;

    void Awake()
    {
        rt = new RenderTexture(256, 256, 16);
        camaraPreview.targetTexture = rt;
        imagen.texture = rt;
        mpb = new MaterialPropertyBlock();
    }

    public void Mostrar(Mesh mesh, Color color)
    {
        meshFilter.sharedMesh = mesh;
        meshFilter.transform.localPosition = -mesh.bounds.center;   // centra el modelo en el pivote

        Vector3 lado = mesh.bounds.size;
        pivote.localScale = Vector3.one * tamanio / Mathf.Max(lado.x, lado.y, lado.z);

        mpb.SetColor("_Color", color);
        meshRenderer.SetPropertyBlock(mpb);
    }

    void LateUpdate()
    {
        pivote.Rotate(Vector3.up, velocidadGiro * Time.deltaTime, Space.World);
        camaraPreview.Render();
    }

    void OnDestroy()
    {
        camaraPreview.targetTexture = null;
        rt.Release();
        Destroy(rt);
    }
}
