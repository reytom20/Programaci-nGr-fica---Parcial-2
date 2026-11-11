using UnityEngine;

// WASD / flechas mueven los binoculares frente a la pared y la rueda acerca o aleja.
public class MoverBinoculares : MonoBehaviour
{
    [SerializeField] float velocidad = 10f;
    [SerializeField] float pasoZoom = 1.5f;
    [SerializeField] Vector2 limite = new Vector2(33f, 18f);
    [SerializeField] float acercamientoMaximo = 18f;

    Vector3 inicio;
    Vector3 desplazamiento;

    void Start()
    {
        inicio = transform.position;
    }

    void Update()
    {
        desplazamiento.x += Input.GetAxis("Horizontal") * velocidad * Time.deltaTime;
        desplazamiento.y += Input.GetAxis("Vertical") * velocidad * Time.deltaTime;
        desplazamiento.z += Input.mouseScrollDelta.y * pasoZoom;

        desplazamiento.x = Mathf.Clamp(desplazamiento.x, -limite.x, limite.x);
        desplazamiento.y = Mathf.Clamp(desplazamiento.y, -limite.y, limite.y);
        desplazamiento.z = Mathf.Clamp(desplazamiento.z, 0f, acercamientoMaximo);

        transform.position = inicio + desplazamiento;
    }
}
