using UnityEngine;


// WASD: moverse | E / Q: subir / bajar | Shift: rapido | Click derecho + mouse: mirar
public class CamaraLibre : MonoBehaviour
{
    [SerializeField] float velocidad = 6f;
    [SerializeField] float multiplicadorRapido = 3f;
    [SerializeField] float sensibilidad = 2.5f;

    float yaw;
    float pitch;

    void Start()
    {
        Vector3 rot = transform.eulerAngles;
        yaw = rot.y;
        pitch = rot.x > 180f ? rot.x - 360f : rot.x;
    }

    void Update()
    {
        if (Input.GetMouseButton(1))
        {
            yaw += Input.GetAxis("Mouse X") * sensibilidad;
            pitch = Mathf.Clamp(pitch - Input.GetAxis("Mouse Y") * sensibilidad, -89f, 89f);
            transform.rotation = Quaternion.Euler(pitch, yaw, 0f);
        }

        Vector3 dir = new Vector3(Input.GetAxisRaw("Horizontal"), 0f, Input.GetAxisRaw("Vertical"));
        if (Input.GetKey(KeyCode.E)) dir.y += 1f;
        if (Input.GetKey(KeyCode.Q)) dir.y -= 1f;

        float v = velocidad * (Input.GetKey(KeyCode.LeftShift) ? multiplicadorRapido : 1f);
        transform.Translate(dir.normalized * v * Time.deltaTime, Space.Self);
    }
}
