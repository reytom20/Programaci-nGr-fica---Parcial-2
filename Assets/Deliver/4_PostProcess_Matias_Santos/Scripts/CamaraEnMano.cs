using System.Collections;
using UnityEngine;

// Modelo de la camara en mano (hijo de la Main Camera).
// Al agarrarla sube hasta el encuadre y despues la vista se balancea como camara en mano.
public class CamaraEnMano : MonoBehaviour
{
    [SerializeField] Vector3 posicionGuardada = new Vector3(0.04f, -0.85f, 0.35f);
    [SerializeField] Vector3 posicionEnMano = new Vector3(0.17f, -0.2f, 0.42f);
    [SerializeField] Vector3 rotacionEnMano = new Vector3(0f, -18f, 2f);
    [SerializeField] float duracionSubir = 1.2f;
    [SerializeField] float balanceo = 0.45f;

    Transform camara;
    Quaternion rotacionBase;
    bool enMano;

    public IEnumerator Subir()
    {
        gameObject.SetActive(true);
        camara = transform.parent;
        rotacionBase = camara.localRotation;

        Quaternion desde = Quaternion.Euler(rotacionEnMano + new Vector3(-40f, 0f, 0f));
        Quaternion hasta = Quaternion.Euler(rotacionEnMano);

        for (float t = 0f; t < duracionSubir; t += Time.deltaTime)
        {
            float k = Mathf.SmoothStep(0f, 1f, t / duracionSubir);
            transform.localPosition = Vector3.Lerp(posicionGuardada, posicionEnMano, k);
            transform.localRotation = Quaternion.Slerp(desde, hasta, k);
            yield return null;
        }
        enMano = true;
    }

    void LateUpdate()
    {
        if (!enMano) return;

        // Ruido Perlin en dos ejes: la vista "respira" como una camara sostenida a mano.
        float x = (Mathf.PerlinNoise(Time.time * 0.35f, 0f) - 0.5f) * 2f * balanceo;
        float y = (Mathf.PerlinNoise(0f, Time.time * 0.3f) - 0.5f) * 2f * balanceo;
        camara.localRotation = rotacionBase * Quaternion.Euler(x, y, 0f);
    }
}
