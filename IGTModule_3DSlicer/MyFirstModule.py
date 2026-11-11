import logging
import os

import vtk

import slicer
from slicer.ScriptedLoadableModule import *
from slicer.util import VTKObservationMixin

import numpy as np
import time
from pathlib import Path
#
# MyFirstModule
#
class MyFirstModule(ScriptedLoadableModule):
 
  def __init__(self, parent):
    """Uses ScriptedLoadableModule base class, available at:
    https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
    """
    ScriptedLoadableModule.__init__(self, parent)
    self.parent.title = "MyFirstModule" # TODO make this more human readable by adding spaces
    self.parent.categories = ["MyIGTModules"]
    self.parent.dependencies = []
    self.parent.contributors = ["Carolina Martin Frisuelos (UC3M), Abril Arias Rojas (UC3M)"] # replace with "Firstname Lastname (Organization)"
    self.parent.helpText = """Lab 3. Practical Session"""
    self.parent.helpText += self.getDefaultModuleDocumentationLink()
    self.parent.acknowledgementText = """Department of Bioengineering, Universidad Carlos III""" 

#
# MyFirstModuleWidget
#

class MyFirstModuleWidget(ScriptedLoadableModuleWidget, VTKObservationMixin):
    """Uses ScriptedLoadableModuleWidget base class, available at:
    https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
    """

    def __init__(self, parent=None):
        """
        Called when the user opens the module the first time and the widget is initialized.
        """
        ScriptedLoadableModuleWidget.__init__(self, parent)
        VTKObservationMixin.__init__(self)  # needed for parameter node observation
        self.logic = None
        self.connect = True
        #self._parameterNode = None
        #self._updatingGUIFromParameterNode = False


    def setup(self):
        """
        Called when the user opens the module the first time and the widget is initialized.
        """
        ScriptedLoadableModuleWidget.setup(self)

        # Load widget from .ui file (created by Qt Designer).
        # Additional widgets can be instantiated manually and added to self.layout.
        uiWidget = slicer.util.loadUI(self.resourcePath('UI/MyFirstModule.ui'))
        self.layout.addWidget(uiWidget)
        self.ui = slicer.util.childWidgetVariables(uiWidget)

        # Set scene in MRML widgets. Make sure that in Qt designer the top-level qMRMLWidget's
        # "mrmlSceneChanged(vtkMRMLScene*)" signal in is connected to each MRML widget's.
        # "setMRMLScene(vtkMRMLScene*)" slot.
        uiWidget.setMRMLScene(slicer.mrmlScene)

        # Create logic class. Logic implements all computations that should be possible to run
        # in batch mode, without a graphical user interface.
        self.logic = MyFirstModuleLogic()

        # Connections

        # These connections ensure that whenever user changes some settings on the GUI, that is saved in the MRML scene
        # (in the selected parameter node).
        self.ui.loadDataButton.connect('clicked(bool)', self.onLoadDataButtonClicked)
        self.ui.connectToPlusButton.connect('clicked(bool)', self.onConnectToPlusButtonClicked)
        self.ui.buildTransformTreeButton.connect('clicked(bool)', self.onBuildTransformTreeButtonClicked)
        self.ui.addPointButton.connect('clicked(bool)', self.onAddPointButtonClicked)
        self.ui.removePointButton.connect('clicked(bool)', self.onRemovePointButtonClicked)
        self.ui.computeRegistrationButton.connect('clicked(bool)', self.onComputeRegistrationButtonClicked)
        self.ui.resetRegistrationButton.connect('clicked(bool)', self.onResetRegistrationButtonClicked)
        self.ui.skullOpacitySlider.connect('valueChanged(double)', self.onSkullOpacityValueSliderWidgetChanged)
        self.ui.brainOpacitySlider.connect('valueChanged(double)', self.onBrainOpacityValueSliderWidgetChanged)
        
    # UI functions
    #
    def onLoadDataButtonClicked(self):
        
        # Load data
        # ---- FILL ----
        print("Loading data")
        self.logic.loadData()

    def onConnectToPlusButtonClicked(self):
    
        # Update button state
        self.ui.connectToPlusButton.enabled = False

        # Update connection 
        if self.connect:
            hostname = '163.117.178.165'
            port_tracker = 18944
            status = self.logic.startPlusConnection(hostname, port_tracker) # Start connection
            if status == 1:
                self.connect = False
                self.ui.connectToPlusButton.setText('Disconnect from Plus')
            else:
                self.logic.stopPlusConnection() # Stop connection
                self.connect = True
                self.ui.connectToPlusButton.setText('Connect to Plus')
        else:
            self.logic.stopPlusConnection() # Stop connection
            self.connect = True
            self.ui.connectToPlusButton.setText('Connect to Plus')       

        # Update button state
        self.ui.connectToPlusButton.enabled = True

    def onBuildTransformTreeButtonClicked(self):
        
        # Build transformation tree
        self.logic.buildTransformTree()
        
    def onAddPointButtonClicked(self):
        
        # Add point
        self.logic.addPoint()
        
    def onRemovePointButtonClicked(self):
        
        # Remove point
        self.logic.removePoint()
        
    def onComputeRegistrationButtonClicked(self):
        
        # Compute registration
        self.logic.computeRegistration()
        
    def onResetRegistrationButtonClicked(self):
        
        # Reset registration
        self.logic.resetRegistration()
        
    def onSkullOpacityValueSliderWidgetChanged(self, opacityValue):

        # Get opacity value
        print('Slider skull:', opacityValue)
        opacityValue_norm = opacityValue/100.0
        
        # Update model opacity
        self.logic.updateSkullModelOpacity(opacityValue_norm)

        
    def onBrainOpacityValueSliderWidgetChanged(self, opacityValue):

        # Get opacity value
        print('Slider brain:', opacityValue)
        opacityValue_norm = opacityValue/100.0
        
        # Update model opacity
        self.logic.updateBrainModelOpacity(opacityValue_norm)
      

#
# MyFirstModuleLogic
#

class MyFirstModuleLogic(ScriptedLoadableModuleLogic):
    """This class should implement all the actual
    computation done by your module.  The interface
    should be such that other python code can import
    this class and make use of the functionality without
    requiring an instance of the Widget.
    Uses ScriptedLoadableModuleLogic base class, available at:
    https://github.com/Slicer/Slicer/blob/master/Base/Python/slicer/ScriptedLoadableModule.py
    """

    def __init__(self):
        """
        Called when the logic class is instantiated. Can be used for initializing member variables.
        """
        ScriptedLoadableModuleLogic.__init__(self)
        self.connect = False
        self.data_path = slicer.modules.myfirstmodule.path.replace("MyFirstModule.py", "") + "Resources/Data"

    

    def process(self, inputVolume, outputVolume, imageThreshold, invert=False, showResult=True):
        """
        Run the processing algorithm.
        Can be used without GUI widget.
        :param inputVolume: volume to be thresholded
        :param outputVolume: thresholding result
        :param imageThreshold: values above/below this threshold will be set to 0
        :param invert: if True then values above the threshold will be set to 0, otherwise values below are set to 0
        :param showResult: show output volume in slice viewers
        """

        if not inputVolume or not outputVolume:
            raise ValueError("Input or output volume is invalid")

        import time
        startTime = time.time()
        logging.info('Processing started')

        # Compute the thresholded output volume using the "Threshold Scalar Volume" CLI module
        cliParams = {
            'InputVolume': inputVolume.GetID(),
            'OutputVolume': outputVolume.GetID(),
            'ThresholdValue': imageThreshold,
            'ThresholdType': 'Above' if invert else 'Below'
        }
        cliNode = slicer.cli.run(slicer.modules.thresholdscalarvolume, None, cliParams, wait_for_completion=True, update_display=showResult)
        # We don't need the CLI module node anymore, remove it to not clutter the scene with it
        slicer.mrmlScene.RemoveNode(cliNode)

        stopTime = time.time()
        logging.info(f'Processing completed in {stopTime-startTime:.2f} seconds')

    def startPlusConnection(self, hostname, port_tracker):
        """
        Starts PLUS connection with optical tracker through selected port.
        """    
        # Open connection
        try:
            cnode = slicer.util.getNode('IGTLConnector_Tracker')
        except:
            cnode = slicer.vtkMRMLIGTLConnectorNode()
            slicer.mrmlScene.AddNode(cnode)
            cnode.SetName('IGTLConnector_Tracker')
        status = cnode.SetTypeClient(hostname, port_tracker)
        
        # Check connection status
        if status == 1:
            cnode.Start()
            logging.debug('Connection Successful')
        
        else:
            print ('ERROR: Unable to connect to PLUS')
            logging.debug('ERROR: Unable to connect to PLUS')

        return status

    def stopPlusConnection(self):
        """
        Stops PLUS connection with optical tracker.
        """    
        cnode = slicer.util.getNode('IGTLConnector_Tracker')
        cnode.Stop()

    def loadModelFromFile(self, modelFilePath, modelFileName, colorRGB_array, visibility_bool):
        try:
            node = slicer.util.getNode(modelFileName)
        except:
            node = slicer.util.loadModel(modelFilePath + '/' + modelFileName)
            node.GetModelDisplayNode().SetColor(colorRGB_array)
            node.GetModelDisplayNode().SetVisibility(visibility_bool)
            print (modelFileName + ' model loaded')

        return node

    def loadTransformFromFile(self, transformFilePath, transformFileName):
        try:
            node = slicer.util.getNode(transformFileName)
        except:
            node = slicer.util.loadTransform(transformFilePath +  '/' + transformFileName)
            if node == None:
                node=slicer.vtkMRMLLinearTransformNode()
                node.SetName(transformFileName)
                slicer.mrmlScene.AddNode(node)
                print ('ERROR: ' + transformFileName + ' transform not found in path. Creating node as identity...')
            
        return node

    def getOrCreateTransform(self, transformName):
        try:
            node = slicer.util.getNode(transformName)
        except:
            node=slicer.vtkMRMLLinearTransformNode()
            node.SetName(transformName)
            slicer.mrmlScene.AddNode(node)
            print ('ERROR: ' + transformName + ' transform was not found. Creating node as identity...')
        return node

    def loadFiducialsFromFile(self, fiducialsFilePath, fiducialsFileName, colorRGB_array, visibility_bool):
        """
        Load point set (fiducials) from FCSV file.
        """
        node = slicer.util.loadMarkups(fiducialsFilePath + '/' + fiducialsFileName)
        node.GetDisplayNode().SetColor(colorRGB_array)
        node.GetDisplayNode().SetVisibility(visibility_bool)
        node.LockedOn()
        print (fiducialsFileName + ' loaded')
        return node

    def getOrCreateFiducials(self, fiducialsName, colorRGB_array, visibility_bool):

        try:
            node = slicer.util.getNode(fiducialsName)
        except:
            node = slicer.vtkMRMLMarkupsFiducialNode()  
            node.SetName(fiducialsName)
            slicer.mrmlScene.AddNode(node)
            node.GetDisplayNode().SetSelectedColor(colorRGB_array)
            node.GetDisplayNode().SetVisibility(visibility_bool)
            node.LockedOn()
        return node

    def loadData(self):
        """
        Loads data for navigation.
        """
        print ('Loading Data...')

        # Load Models
        self.stylus_model = self.loadModelFromFile(self.data_path,'stylus_model.stl', [0.96, 0.96, 0.00],True)
        self.skull_model = self.loadModelFromFile(self.data_path,'skull_model.stl', [0.80, 0.81, 0.64],True)
        self.brain_model = self.loadModelFromFile(self.data_path,'brain_model.stl', [0.81, 0.64, 0.52],True)
        self.tumor_model = self.loadModelFromFile(self.data_path,'tumor_model.stl', [0.00, 0.99, 0.00],True)

        # Load  stylusTipToStylus transform
        self.StylusTipToStylus = self.loadTransformFromFile(self.data_path,'StylusTipToStylus.h5')

        # Create referenceToRas transform
        self.ReferenceToRas = self.getOrCreateTransform('ReferenceToRas')

        # Load registration virtual fiducials
        self.registration_Virtual_Fiducials = self.loadFiducialsFromFile(self.data_path,'registration_Virtual_Fiducials.fcsv', [1.00, 0.00, 0.00],True)

        # Create registration real fiducials
        self.registration_Real_Fiducials = self.getOrCreateFiducials('registration_Real_Fiducials',[0.00, 0.00, 1.00],True)

    def buildTransformTree(self):
        """
        Builds transform tree for navigation.
        """
        print ('Building transform tree...')

        # Get transforms if received from PLUS toolkit
        self.StylusToTracker = self.getOrCreateTransform('StylusToTracker')
        self.TrackerToReference = self.getOrCreateTransform('TrackerToReference')

        # Build transform tree
        self.stylus_model.SetAndObserveTransformNodeID(self.StylusTipToStylus.GetID())
        self.StylusTipToStylus.SetAndObserveTransformNodeID(self.StylusToTracker.GetID())
        self.StylusToTracker.SetAndObserveTransformNodeID(self.TrackerToReference.GetID())
        self.TrackerToReference.SetAndObserveTransformNodeID(self.ReferenceToRas.GetID())

    def addPoint(self):
        """
        Adds new point for registration.
        """
        # Get stylus tip position
        m = vtk.vtkMatrix4x4()
        self.StylusTipToStylus.GetMatrixTransformToWorld(m)
        fiducial = [m.GetElement(0,3),m.GetElement(1,3),m.GetElement(2,3)]

        # Add fiducial to list
        self.registration_Real_Fiducials.AddControlPoint(fiducial)
        
        # Update fiducials display
        numFiducials = self.registration_Real_Fiducials.GetNumberOfControlPoints()
        print ('Number of fiducials: ', numFiducials)

    def removePoint(self):
        """
        Removes last recorded point.
        """
        # Get number of fiducials
        numFiducials = self.registration_Real_Fiducials.GetNumberOfControlPoints()    

        # Delete last fiducial of the list
        if numFiducials > 0:
         self.registration_Real_Fiducials.RemoveNthControlPoint(numFiducials - 1)   

        # Update fiducials display
        numFiducials = self.registration_Real_Fiducials.GetNumberOfControlPoints()
        print ('Number of fiducials: ', numFiducials)
        

    def calculateRegistrationAndRMSError(self, fixedFiducials, movingFiducials, registrationResultTransform):
        """
        Computes registration between a moving and a fixed point set, and calculates the root mean squared error of the registration.
        """
        # Define parameters for registration
        parameters = {}
        parameters["fixedLandmarks"] = fixedFiducials.GetID()
        parameters["movingLandmarks"] = movingFiducials.GetID()
        parameters["saveTransform"] = registrationResultTransform.GetID()
        parameters["rms"] = 0.0
        parameters["transformType"] = "Rigid"

        # Perform registration
        node  = slicer.cli.createNode(slicer.modules.fiducialregistration)
        fidReg = slicer.modules.fiducialregistration
        slicer.cli.run(fidReg, node, parameters, True)
        
        # Output
        outputMessage = node.GetParameterAsString('outputMessage')
        errorRMS = node.GetParameterAsString('rms')

        return (errorRMS, outputMessage)

    def computeRegistration(self):

        # Compute registration 
        errorRMS, outputMessage = self.calculateRegistrationAndRMSError(
        self.registration_Virtual_Fiducials,   # fixed
        self.registration_Real_Fiducials,      # moving
        self.ReferenceToRas)                   # result
        print ('RMS error: ' + errorRMS)
        print ('Output message: ' + outputMessage)
        
    def resetRegistration(self):

        # Delete fiducials
        self.registration_Real_Fiducials.RemoveAllControlPoints()

        # Update display
        numFiducials = self.registration_Real_Fiducials.GetNumberOfControlPoints()
        print ('Number of fiducials: ', numFiducials)

        # Set transform ReferenceToRas to identity
        identityTransform = vtk.vtkMatrix4x4()
        self.ReferenceToRas.SetMatrixTransformToParent(identityTransform)

    def updateSkullModelOpacity(self, opacityValue_norm):

        if hasattr(self, 'skull_model'):
         self.skull_model.GetDisplayNode().SetOpacity(opacityValue_norm)

    

    def updateBrainModelOpacity(self, opacityValue_norm):

        if hasattr(self, 'brain_model'):
         self.brain_model.GetDisplayNode().SetOpacity(opacityValue_norm)


