using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

// 1. Despertar (parpadeo)  2. Flashbang  3. Camara en mano (vision nocturna).
// R reinicia la escena.
public class Secuencia : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] PostProcess post;
    [SerializeField] Transform granada;
    [SerializeField] Transform granadaInicio;
    [SerializeField] Transform granadaFin;
    [SerializeField] GameObject luzExplosion;
    [SerializeField] GameObject esferaExplosion;
    [SerializeField] CamaraEnMano camaraEnMano;
    [SerializeField] GameObject hudCamara;
    [SerializeField] GameObject cartelAgarrar;

    [Header("Despertar")]
    [SerializeField] float duracionDespertar = 6f;
    [SerializeField] float intervaloParpadeo = 1.6f;
    [SerializeField] float duracionParpadeo = 0.35f;

    [Header("Flashbang")]
    [SerializeField] float duracionRodar = 1.5f;
    [SerializeField] float flashSostenido = 1f;
    [SerializeField] float flashDesvanecer = 3f;
    [SerializeField] float fantasmaMaximo = 0.6f;

    [Header("Recuperacion")]
    [SerializeField] float duracionRecuperacion = 4f;

    IEnumerator Start()
    {
        granada.gameObject.SetActive(false);
        hudCamara.SetActive(false);
        cartelAgarrar.SetActive(false);

        // 1. Despertar: los ojos se abren de a poco y parpadean.
        post.parpadeo = true;
        yield return Parpadear(duracionDespertar, 0f);

        // 2. Flashbang: rueda la granada, se congela la imagen y la pantalla se va a blanco.
        yield return RodarGranada();
        post.CapturarFantasma();
        yield return Explotar();
        yield return Flash();

        // Recuperacion: vuelven los parpadeos, cada vez mas abiertos.
        yield return Parpadear(duracionRecuperacion, 0.6f);
        post.parpadeo = false;

        // 3. Camara en mano: se agarra con E y se enciende la vision nocturna.
        cartelAgarrar.SetActive(true);
        while (!Input.GetKeyDown(KeyCode.E)) yield return null;
        cartelAgarrar.SetActive(false);

        yield return camaraEnMano.Subir();
        hudCamara.SetActive(true);
        post.camara = true;
        for (float t = 0f; t < 1f; t += Time.deltaTime * 2f)
        {
            post.matCamara.SetFloat("_Amount", t);
            yield return null;
        }
        post.matCamara.SetFloat("_Amount", 1f);
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.R)) SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }

    // Abre los ojos desde "aperturaInicial" hasta 1, cerrandolos cada "intervaloParpadeo".
    IEnumerator Parpadear(float duracion, float aperturaInicial)
    {
        for (float t = 0f; t < duracion; t += Time.deltaTime)
        {
            float abierto = Mathf.Lerp(aperturaInicial, 1f, t / duracion);

            float fase = t % intervaloParpadeo;
            if (fase < duracionParpadeo)
                abierto *= Mathf.Abs(fase / duracionParpadeo * 2f - 1f);   // cierra y vuelve a abrir

            post.matParpadeo.SetFloat("_Open", abierto);
            post.matParpadeo.SetFloat("_Blur", 1f - abierto);
            yield return null;
        }
        post.matParpadeo.SetFloat("_Open", 1f);
        post.matParpadeo.SetFloat("_Blur", 0f);
    }

    IEnumerator RodarGranada()
    {
        granada.gameObject.SetActive(true);
        luzExplosion.SetActive(false);
        esferaExplosion.SetActive(false);

        for (float t = 0f; t < duracionRodar; t += Time.deltaTime)
        {
            granada.position = Vector3.Lerp(granadaInicio.position, granadaFin.position, Mathf.SmoothStep(0f, 1f, t / duracionRodar));
            granada.Rotate(Vector3.right, 900f * Time.deltaTime);
            yield return null;
        }
    }

    IEnumerator Explotar()
    {
        luzExplosion.SetActive(true);
        esferaExplosion.SetActive(true);
        yield return new WaitForSeconds(0.12f);
        granada.gameObject.SetActive(false);
    }

    IEnumerator Flash()
    {
        post.flashbang = true;
        float total = flashSostenido + flashDesvanecer;

        for (float t = 0f; t < total; t += Time.deltaTime)
        {
            float flash = t < flashSostenido ? 1f : 1f - (t - flashSostenido) / flashDesvanecer;
            post.matFlashbang.SetFloat("_Flash", flash);
            post.matFlashbang.SetFloat("_GhostAlpha", fantasmaMaximo * (1f - t / total));
            yield return null;
        }
        post.flashbang = false;
    }
}
