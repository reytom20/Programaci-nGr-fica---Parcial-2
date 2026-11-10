using UnityEngine;

[RequireComponent(typeof(Projector))]
public class DayCycleProjector : MonoBehaviour
{
    [Range(0f, 24f)] public float hour = 8f;
    public bool autoPlay = true;
    public float hoursPerSecond = 0.3f;

    [Header("Hacia dónde apunta la luz")]
    public Transform target;          // un Empty en el centro del piso
    public float sweepWidth = 3f;     // metros hacia los lados
    public float sweepDepth = 2f;     // metros hacia adelante/atrás

    [Header("Luz")]
    public Color dawnColor = new Color(1f, 0.55f, 0.3f);
    public Color noonColor = new Color(1f, 0.95f, 0.85f);
    public Color duskColor = new Color(1f, 0.4f, 0.2f);
    public float maxIntensity = 1.2f;

    [Header("Nombres de propiedades del shader")]
    public string colorProperty = "_LightColor";
    public string intensityProperty = "_Intensity";

    Projector proj;
    Material mat;

    void Start()
    {
        proj = GetComponent<Projector>();
        mat = new Material(proj.material); // copia, no modifica el asset
        proj.material = mat;
    }

    void Update()
    {
        if (autoPlay)
        {
            hour += hoursPerSecond * Time.deltaTime;
            if (hour > 18f) hour = 6f; // salta la noche
        }

        float t = Mathf.InverseLerp(6f, 18f, hour); // 0 = 6 h, 1 = 18 h
        float arc = Mathf.Sin(t * Mathf.PI);        // 0 → 1 → 0

        if (target != null)
        {
            // lateral: de un lado a otro; profundidad: lejos de mañana y tarde, cerca al mediodía
            Vector3 aim = target.position
                + target.right * Mathf.Lerp(-sweepWidth, sweepWidth, t)
                + target.forward * Mathf.Lerp(sweepDepth, -sweepDepth, arc);
            transform.LookAt(aim);
        }

        Color c = t < 0.5f
            ? Color.Lerp(dawnColor, noonColor, t * 2f)
            : Color.Lerp(noonColor, duskColor, (t - 0.5f) * 2f);

        mat.SetColor(colorProperty, c);
        mat.SetFloat(intensityProperty, arc * maxIntensity);
    }
}