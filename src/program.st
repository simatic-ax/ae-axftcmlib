USING Simatic;
USING Simatic.Ax.axftcmlib;
//Additionally needed
USING Simatic.Ax.IO.Output;
USING Simatic.Ax.IO.Input;

PROGRAM ExampleForAxftcm_Program
    ///Functrion:
    /// If an element is added to the front lightbarrier, it activates the conveyor
    /// the conveyor moves the piece to the cylinder, where it is pushed into the chute
    VAR_EXTERNAL
        //All global variables used in this Programm have to be "included" as VAR_EXTERNAL
        SortinglineStartingLightbarrier     : BOOL;
        SortinglineEndLightbarrier          : BOOL;
        SortinglineMotorForConveyor         : BOOL;
        SortinglineCompressor               : BOOL;
        SortinglineValveEjector             : BOOL;

        CompressorOutputWriter              : BinOutput;
        CylinderOutputWriter                : BinOutput;
        MotorForwardOutputWriter            : BinOutput;
        MotorBackwardsOutputWriter          : BinOutput;

        StartingLightbarriereReader         : BinSignal;
        EndingLightbarrierReader            : BinSignal;
        AxisReferenceswitch                 : BinSignal;

        CompressorClassInstance             : PneumaticCompressor;
        CylinderClassInstance               : PneumaticCylinder;  

        TimeproviderForAxis                 : Timeprovider;
        MotorForAxis                        : MotorFT;
        TimebasedEncoderForAxis             : TimeBasedEncoder;
        ConveyorbeltForSortingline          : Axis;
        
        Statecounter                        : INT;
    END_VAR

    VAR
        //Local variables could be added here but note that they cant be monitored
    END_VAR

    ///Reading the state of the lightbarrier every Cycle
    StartingLightbarriereReader.ReadCyclic(SortinglineStartingLightbarrier);
    EndingLightbarrierReader.ReadCyclic(SortinglineEndLightbarrier);

    ///Needs to be called in every cycle
    CylinderClassInstance.RunCyclic();
    ConveyorbeltForSortingline.RunCyclic();

    ///Get and Process the cycletime every cycle
    TimebasedEncoderForAxis.Evaluate();
    TimeproviderForAxis.Evaluate();

    IF Statecounter = 0 AND StartingLightbarriereReader.QRis() THEN
       ConveyorbeltForSortingline.Homing(Position := 0);
        ConveyorbeltForSortingline.MoveAbsolute(Velocity := 1.0, Position := 4150); 
        Statecounter := 1;
    END_IF;
    
    IF Statecounter = 1 AND EndingLightbarrierReader.QRis() THEN
        CompressorClassInstance.PneumaticCompressorOn();
        Statecounter := 2;
    END_IF;

    IF Statecounter = 2 AND EndingLightbarrierReader.QFal() THEN
        CylinderClassInstance.Start();
        Statecounter := 0;
    END_IF;
    
    //Actually writing the results onto the PLCs variables
    CylinderOutputWriter.WriteCyclic(Q => SortinglineValveEjector);
    CompressorOutputWriter.WriteCyclic(Q => SortinglineCompressor);
    MotorForwardOutputWriter.WriteCyclic(Q => SortinglineMotorForConveyor);

    ;
END_PROGRAM
