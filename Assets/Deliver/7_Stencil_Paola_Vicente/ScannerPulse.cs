
using System.Collections;
using UnityEngine;
using UnityEngine.InputSystem;

public class ScannerPulse : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private GameObject scannerSphere;
    [SerializeField] private Transform player;

    [Header("Scanner Settings")]
    [SerializeField] private float maxRadius = 9f;
    [SerializeField] private float duration = 8f;

    private bool isScanning;

    //variables propias de la clase
    private static readonly int ScannerPositionID = Shader.PropertyToID("ScannerPosition");

    private static readonly int ScannerRadiusID = Shader.PropertyToID("ScannerRadius");

    private void Start()
    {
        scannerSphere.SetActive(false);
        Shader.SetGlobalFloat(ScannerRadiusID, 0f);
    }

    private void Update()
    {
        if (Keyboard.current != null && Keyboard.current.spaceKey.wasPressedThisFrame && !isScanning)
        {
            StartCoroutine(Scan());
        }
    }

    private IEnumerator Scan()
    {
        isScanning = true;

        Vector3 scanOrigin = player.position;

        scannerSphere.transform.position = scanOrigin;
        scannerSphere.transform.localScale = Vector3.zero;
        scannerSphere.SetActive(true);

        //transmite el origen del escaneo a los shaders que leen esta propiedad global "ScannerPosition"
        Shader.SetGlobalVector(ScannerPositionID, scanOrigin);

        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;

            float progress = Mathf.Clamp01(elapsed / duration); //convierte el tiempo transcurrido en un porcentaje entre 0 y 1

            float radius = Mathf.Lerp(0f, maxRadius, progress); //calcula un radio que crece linealmente de 0 a maxRadius progresivamente (segun el tiempo)

            scannerSphere.transform.localScale = Vector3.one * radius * 2f;

            Shader.SetGlobalFloat(ScannerRadiusID, radius);

            yield return null;
        }

        scannerSphere.SetActive(false);
        Shader.SetGlobalFloat(ScannerRadiusID, 0f);
        
        isScanning = false;
    }
}
