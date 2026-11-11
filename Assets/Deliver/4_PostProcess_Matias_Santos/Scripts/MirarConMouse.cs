using UnityEngine;

// Mirar con el mouse, con limites para no perder el cuarto de vista.
public class MirarConMouse : MonoBehaviour
{
    [SerializeField] Transform pivoteHorizontal;
    [SerializeField] Transform pivoteVertical;
    [SerializeField] float sensibilidad = 2.5f;
    [SerializeField] float limiteHorizontal = 70f;
    [SerializeField] float limiteVertical = 60f;

    float horizontal;
    float vertical;

    void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;
    }

    void Update()
    {
        horizontal = Mathf.Clamp(horizontal + Input.GetAxis("Mouse X") * sensibilidad, -limiteHorizontal, limiteHorizontal);
        vertical = Mathf.Clamp(vertical - Input.GetAxis("Mouse Y") * sensibilidad, -limiteVertical, limiteVertical);

        pivoteHorizontal.localRotation = Quaternion.Euler(0f, horizontal, 0f);
        pivoteVertical.localRotation = Quaternion.Euler(vertical, 0f, 0f);
    }
}
