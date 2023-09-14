USING Simatic;
USING Simatic.Ax.axftcmlib;
//Additionally needed
USING Simatic.Ax.IO.Output;
USING Simatic.Ax.IO.Input;

CONFIGURATION axftcmlibconfig
    TASK Main(Interval := T#100ms, Priority := 1);
    PROGRAM P1 WITH Main: ExampleForAxftcm_Program;
            
    VAR_GLOBAL
        //All PLC-Variables used 
        SortinglineStartingLightbarrier     AT %I200.1 : BOOL;
        SortinglineEndLightbarrier          AT %I200.2 : BOOL;
        SortinglineMotorForConveyor         AT %Q200.0 : BOOL;
        SortinglineCompressor               AT %Q200.1 : BOOL;
        SortinglineValveEjector             AT %Q200.3 : BOOL;
    END_VAR

    VAR_GLOBAL
        //Binoutputs are used to cyclicly write on the PLC-Variables
        //They help with communicating and are used in the axftcmlib
        //ALso available on GitHub as a separate repository (IO)
        CompressorOutputWriter      : BinOutput;
        CylinderOutputWriter        : BinOutput;
        MotorForwardOutputWriter    : BinOutput;
        MotorBackwardsOutputWriter  : BinOutput;
        

        //BinSignals are used to track inputs from the model
        //ALso included in the IO libraray 
        //The Output is inverted because the lightbarrieres return False if they detect something
        StartingLightbarriereReader : BinSignal := (Invert := TRUE);
        EndingLightbarrierReader    : BinSignal := (Invert := TRUE);
        AxisReferenceswitch         : BinSignal;

        //Actual instances of the Elements used in the sortingline
        CompressorClassInstance         :   PneumaticCompressor :=  (ActiveCompressor := CompressorOutputWriter);
        CylinderClassInstance           :   PneumaticCylinder   :=  (CoilPushing      := CylinderOutputWriter);
        
        //Axis:
        //An Encoder as well as a Timeprovider are needed to gereate the current position of the conveyorbelt
        TimeproviderForAxis             : Timeprovider;
        MotorForAxis                    : MotorFT           := (Forward := MotorForwardOutputWriter, Reverse := MotorBackwardsOutputWriter);
        TimebasedEncoderForAxis         : TimeBasedEncoder  := (Timeprovider := TimeproviderForAxis, EncoderAxis := ConveyorbeltForSortingline, Velocity := 1.0);
        ConveyorbeltForSortingline      : Axis              := (Motor :=  MotorForAxis, Encoder := TimebasedEncoderForAxis, ReferenceSwitch := AxisReferenceswitch);

        //Controlvariables
        Statecounter                    : INT               := (0); 

    END_VAR
END_CONFIGURATION
