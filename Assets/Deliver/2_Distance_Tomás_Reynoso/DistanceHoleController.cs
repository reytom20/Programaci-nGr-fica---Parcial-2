using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DistanceHoleController : MonoBehaviour
{
    [SerializeField] private Transform player;
    [SerializeField] private Renderer[] obstacles;

    private static readonly int PlayerPosition =
        Shader.PropertyToID("_PlayerPosition");

    private MaterialPropertyBlock propertyBlock;

    private void Awake()
    {
        propertyBlock = new MaterialPropertyBlock();
    }

    private void LateUpdate()
    {
        if (player == null) return;

        Vector3 position = player.position;

        foreach (Renderer obstacle in obstacles)
        {
            if (obstacle == null) continue;

            obstacle.GetPropertyBlock(propertyBlock);
            propertyBlock.SetVector(PlayerPosition, position);
            obstacle.SetPropertyBlock(propertyBlock);
        }
    }
}

