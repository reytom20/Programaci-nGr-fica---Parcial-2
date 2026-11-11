using System.Collections;
using UnityEngine;
using UnityEngine.UI;

// Rondas
// click con la mira sobre el objeto correcto -> foto a la RT -> se muestra
// nueva pared nuevo objetivo
public class Juego : MonoBehaviour
{
    [Header("Referencias")]
    [SerializeField] CampoDeObjetos campo;
    [SerializeField] CamaraFoto camaraFoto;
    [SerializeField] MoverBinoculares binoculares;
    [SerializeField] TarjetaObjetivo tarjeta;
    [SerializeField] GameObject tarjetaUI;
    [SerializeField] GameObject popupFoto;
    [SerializeField] RawImage imagenFoto;
    [SerializeField] RawImage ultimaFoto;      
    [SerializeField] GameObject ultimaFotoUI;  
    [SerializeField] Text textoRonda;
    [SerializeField] Text textoError;

    [SerializeField] float duracionPopup = 3f;

    int ronda = 1;
    bool ocupado;

    void Start()
    {
        imagenFoto.texture = camaraFoto.Foto;
        ultimaFoto.texture = camaraFoto.Foto;
        ultimaFotoUI.SetActive(false);   
        popupFoto.SetActive(false);
        textoError.text = "";
        NuevaRonda();
    }

    void Update()
    {
        if (ocupado || !Input.GetMouseButtonDown(0)) return;

        // Rayo desde el centro de la pantalla (donde esta la mira).
        Ray rayo = Camera.main.ViewportPointToRay(new Vector3(0.5f, 0.5f, 0f));
        int objeto = campo.ObjetoEn(rayo);

        if (objeto == campo.Objetivo) StartCoroutine(Encontrado());
        else if (objeto >= 0) StartCoroutine(Error());
    }

    IEnumerator Encontrado()
    {
        ocupado = true;
        binoculares.enabled = false;

        yield return camaraFoto.SacarFoto();
        yield return camaraFoto.Flash();
        ultimaFotoUI.SetActive(true);

        // Se muestra la foto guardada en la RT.
        tarjetaUI.SetActive(false);
        popupFoto.SetActive(true);
        for (float t = 0f; t < duracionPopup; t += Time.deltaTime)
        {
            if (t > 0.5f && Input.GetMouseButtonDown(0)) break;
            yield return null;
        }
        popupFoto.SetActive(false);

        ronda++;
        NuevaRonda();
        binoculares.enabled = true;
        ocupado = false;
    }

    IEnumerator Error()
    {
        textoError.text = "No es ese objeto";
        yield return new WaitForSeconds(1f);
        textoError.text = "";
    }

    void NuevaRonda()
    {
        campo.Generar();
        tarjeta.Mostrar(campo.MeshObjetivo, campo.ColorObjetivo);
        tarjetaUI.SetActive(true);
        textoRonda.text = "Ronda " + ronda;
    }
}
