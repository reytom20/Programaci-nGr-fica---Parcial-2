
using UnityEngine;

[RequireComponent(typeof(RectTransform))]
public class WaterInteractable : MonoBehaviour
{
    [SerializeField] private WaterInteractionController waterController;

    public RectTransform RectTransform { get; private set; }

    private void Awake()
    {
        RectTransform = GetComponent<RectTransform>();
    }

    private void OnEnable()
    {
        if (waterController != null)
            waterController.RegisterInteractable(this);
    }

    private void OnDisable()
    {
        if (waterController != null)
            waterController.UnregisterInteractable(this);
    }
}


