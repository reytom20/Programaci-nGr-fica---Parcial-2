using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CardSpin : MonoBehaviour
{
    public float speed = 40f;

    void Update()
    {
        transform.Rotate(0f, speed * Time.deltaTime, 0f);
    }
}