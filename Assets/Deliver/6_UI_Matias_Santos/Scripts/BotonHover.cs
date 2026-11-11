using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

// Punto 6: al pasar el mouse sobre el boton, el Flow corre mas rapido y brilla mas.
[RequireComponent(typeof(Image))]
public class BotonHover : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
{
    [SerializeField] float velocidadNormal = 0.4f;
    [SerializeField] float velocidadHover = 1.5f;
    [SerializeField] Color brilloNormal = new Color(0.3f, 0.2f, 0.1f, 1f);
    [SerializeField] Color brilloHover = new Color(0.6f, 0.42f, 0.2f, 1f);
    [SerializeField] float suavizado = 8f;

    static readonly int FlowSpeed = Shader.PropertyToID("_FlowSpeed");
    static readonly int FlowTint = Shader.PropertyToID("_FlowTint");

    Material mat;
    float t;      // 0 = normal, 1 = hover
    bool encima;

    void Awake()
    {
        // En UI no hay MaterialPropertyBlock: instanciamos para no tocar el asset.
        Image img = GetComponent<Image>();
        mat = new Material(img.material);
        img.material = mat;
    }

    public void OnPointerEnter(PointerEventData e) { encima = true; }
    public void OnPointerExit(PointerEventData e) { encima = false; }

    void Update()
    {
        t = Mathf.MoveTowards(t, encima ? 1f : 0f, Time.deltaTime * suavizado);
        mat.SetFloat(FlowSpeed, Mathf.Lerp(velocidadNormal, velocidadHover, t));
        mat.SetColor(FlowTint, Color.Lerp(brilloNormal, brilloHover, t));
    }

    void OnDestroy()
    {
        Destroy(mat);
    }
}
