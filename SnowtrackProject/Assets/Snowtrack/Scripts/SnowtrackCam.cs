using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class SnowtrackCam : MonoBehaviour
{
    /// <summary> A description of the elements for this project
    /// snowPlaneTrans: the transform information of snow plane
    /// depthFillMat: the material for initialize the camera depth map (set all pixel color in depth map to 1, which is white)
    /// snowUpdateMat: a simple material for updating the camera depth map
    /// camDepthTexture: camera depth map
    /// snowParticle: a particle to make the scene looks better
    /// depthCam: the camera we used for render the depth map
    /// isDepthTexFilled: a bool value for us to check whether the depth map is initialized
    /// </summary>
    [Header("Project Elements")]
    [SerializeField] private Transform snowPlaneTrans;
    [SerializeField] private Material depthFillMat;
    [SerializeField] private Material snowUpdateMat;
    [SerializeField] private RenderTexture camDepthTexture;
    [SerializeField] private ParticleSystem snowParticle;

    private Camera depthCam;
    private bool isDepthTexFilled = false;

    /// <summary> A description of the UI elements
    /// snowParticleTog: enable/disable the snow particle
    /// showDephMapTog: show/hide the camera depth map
    /// resetSceneBtn: reset the scene
    /// quitBtn: Quit the application;
    /// </summary>
    [Header("UI Elements")]
    [SerializeField] private Toggle snowParticleTog;
    [SerializeField] private Toggle showDepthMapTog;
    [SerializeField] private Button resetSceneBtn;
    [SerializeField] private Button quitBtn;

    private bool isShowingDepthMap = false;

    //This function is called when the scene is started
    private void Start()
    {
        //get the camera component
        depthCam = GetComponent<Camera>();
        //turn to depth texture mode, set the size to the plane size
        depthCam.depthTextureMode = DepthTextureMode.Depth;
        depthCam.orthographicSize *= snowPlaneTrans.localScale.x;

        //set up events for UI elements
        snowParticleTog.onValueChanged.AddListener(SnowParticleToggleHandler);
        showDepthMapTog.onValueChanged.AddListener(ShowDepthMapToggleHandler);
        resetSceneBtn.onClick.AddListener(ResetSceneHandler);
        quitBtn.onClick.AddListener(QuitHandler);
    }

    //This function is called once per frame
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (isDepthTexFilled == false)
        {
            //if we haven't initialize the camera depth map, initialize it
            Graphics.Blit(source, destination, depthFillMat);
            isDepthTexFilled = true;
            return;
        }
        else
        {
            //else, just update the map
            Graphics.Blit(source, destination, snowUpdateMat);
        }
    }

    //This function is for drawing the camera depth map
    private void OnGUI()
    {
        if (isShowingDepthMap)
        {
            GUI.DrawTexture(new Rect(0, 0, 256, 256), camDepthTexture, ScaleMode.ScaleToFit);
        }
    }

    #region UI Event Handlers
    private void SnowParticleToggleHandler(bool isOn)
    {
        if(isOn)
        {
            snowParticle.Play();
        }
        else
        {
            snowParticle.Stop();
        }
    }

    private void ShowDepthMapToggleHandler(bool isOn)
    {
        isShowingDepthMap = isOn;
    }

    private void ResetSceneHandler()
    {
        SceneManager.LoadScene(0);
    }

    private void QuitHandler()
    {
        Application.Quit();
    }    
    #endregion
}
