using System.Collections;
using UnityEngine;
using UnityEngine.UI;

// pasa de la portada a la pantalla de carga y simula el progreso.
public class PantallaCarga : MonoBehaviour
{
    [Header("Paneles")]
    [SerializeField] GameObject panelPortada;
    [SerializeField] GameObject panelCarga;
    [SerializeField] CanvasGroup grupoPortada;

    [Header("Carga")]
    [SerializeField] Image barraRelleno;      // Image Type = Filled (Horizontal)
    [SerializeField] Text textoPorcentaje;
    [SerializeField] float duracionCarga = 6f;

    [Header("Engranaje (Rotation): gira mas rapido con el progreso")]
    [SerializeField] Image reloj;
    [SerializeField] float velocidadMin = 0.5f;
    [SerializeField] float velocidadMax = 5f;

    [Header("Transicion (Distortion del fondo de la portada)")]
    [SerializeField] Image fondoPortada;
    [SerializeField] float duracionTransicion = 0.6f;
    [SerializeField] float distorsionMaxima = 1f;

    static readonly int RotateSpeed = Shader.PropertyToID("_RotateSpeed");
    static readonly int DistortAmount = Shader.PropertyToID("_DistortAmount");

    Material matReloj;
    Material matFondo;
    float distorsionBase;
    float progreso;
    bool cargando;

    void Awake()
    {
        
        matReloj = new Material(reloj.material);
        reloj.material = matReloj;
        matFondo = new Material(fondoPortada.material);
        fondoPortada.material = matFondo;
        distorsionBase = matFondo.GetFloat(DistortAmount);
    }

    void Start()
    {
        MostrarPortada();
    }

    // boton JUGAR.
    public void IniciarCarga()
    {
        if (!cargando) StartCoroutine(Transicion());
    }

    IEnumerator Transicion()
    {
        cargando = true;
        grupoPortada.interactable = false;

        // La portada se deforma y se desvanece antes de pasar a la carga
        for (float t = 0f; t < 1f; t += Time.deltaTime / duracionTransicion)
        {
            matFondo.SetFloat(DistortAmount, Mathf.Lerp(distorsionBase, distorsionMaxima, t));
            grupoPortada.alpha = 1f - t;
            yield return null;
        }

        progreso = 0f;
        panelPortada.SetActive(false);
        panelCarga.SetActive(true);
    }

    void Update()
    {
        if (!cargando || !panelCarga.activeSelf) return;

        progreso += Time.deltaTime / duracionCarga;
        barraRelleno.fillAmount = progreso;
        textoPorcentaje.text = "Cargando... " + Mathf.FloorToInt(Mathf.Clamp01(progreso) * 100f) + "%";
        matReloj.SetFloat(RotateSpeed, Mathf.Lerp(velocidadMin, velocidadMax, progreso));

        //vuelve a la portada para poder mostrarlo en loop
        if (progreso >= 1f) MostrarPortada();
    }

    void MostrarPortada()
    {
        cargando = false;
        matFondo.SetFloat(DistortAmount, distorsionBase);
        grupoPortada.alpha = 1f;
        grupoPortada.interactable = true;
        panelPortada.SetActive(true);
        panelCarga.SetActive(false);
    }

    void OnDestroy()
    {
        Destroy(matReloj);
        Destroy(matFondo);
    }
}
