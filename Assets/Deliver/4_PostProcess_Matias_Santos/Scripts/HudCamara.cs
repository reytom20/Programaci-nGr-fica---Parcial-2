using UnityEngine;
using UnityEngine.UI;

// HUD de la camara: el punto REC titila y el contador de tiempo avanza.
// Es UI en Screen Space Overlay, asi que el post-proceso no lo afecta.
public class HudCamara : MonoBehaviour
{
    [SerializeField] Image puntoRec;
    [SerializeField] Text tiempo;

    float segundos;

    void Update()
    {
        segundos += Time.deltaTime;
        puntoRec.enabled = segundos % 1f < 0.6f;
        tiempo.text = System.TimeSpan.FromSeconds(segundos).ToString(@"hh\:mm\:ss");
    }
}
