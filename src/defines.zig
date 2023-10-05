const std = @import("std");

pub const VelocitySet = enum {
    D2Q9, // choose D2Q9 velocity set for 2D; allocates 53 (FP32) or 35 (FP16) Bytes/cell
    D3Q15, // choose D3Q15 velocity set for 3D; allocates 77 (FP32) or 47 (FP16) Bytes/cell
    D3Q19, // choose D3Q19 velocity set for 3D; allocates 93 (FP32) or 55 (FP16) Bytes/cell; (default)
    D3Q27, // choose D3Q27 velocity set for 3D; allocates 125 (FP32) or 71 (FP16) Bytes/cell
};

pub const RelaxationTime = enum {
    SRT, // choose single-relaxation-time LBM collision operator; (default)
    TRT, // choose two-relaxation-time LBM collision operator
};

pub const FloatingPointCompresson = enum {
    FP16S, // compress LBM DDFs to range-shifted IEEE-754 FP16; number conversion is done in hardware; all arithmetic is still done in FP32
    FP16C, // compress LBM DDFs to more accurate custom FP16C format; number conversion is emulated in software; all arithmetic is still done in FP32
};

pub const GlobalOptions = struct {
    VOLUME_FORCE: bool = false, // enables global force per volume in one direction (equivalent to a pressure gradient); specified in the LBM class constructor; the force can be changed on-the-fly between time steps at no performance cost
    FORCE_FIELD: bool = false, // enables computing the forces on solid boundaries with lbm.calculate_force_on_boundaries(); and enables setting the force for each lattice point independently (enable VOLUME_FORCE too); allocates an extra 12 Bytes/cell
    EQUILIBRIUM_BOUNDARIES: bool = false, // enables fixing the velocity/density by marking cells with TYPE_E; can be used for inflow/outflow; does not reflect shock waves
    MOVING_BOUNDARIES: bool = false, // enables moving solids: set solid cells to TYPE_S and set their velocity u unequal to zero
    SURFACE: bool = false, // enables free surface LBM: mark fluid cells with TYPE_F; at initialization the TYPE_I interface and TYPE_G gas domains will automatically be completed; allocates an extra 12 Bytes/cell
    TEMPERATURE: bool = false, // enables temperature extension; set fixed-temperature cells with TYPE_T (similar to EQUILIBRIUM_BOUNDARIES); allocates an extra 32 (FP32) or 18 (FP16) Bytes/cell
    SUBGRID: bool = false, // enables Smagorinsky-Lilly subgrid turbulence LES model to keep simulations with very large Reynolds number stable
    PARTICLES: bool = false, // enables particles with immersed-boundary method (for 2-way coupling also activate VOLUME_FORCE and FORCE_FIELD; only supported in single-GPU)
    UPDATE_FIELDS: bool = false,
    pub fn init() GlobalOptions {
        return GlobalOptions{};
    }
};

pub const GraphicsMode = enum {
    Interactive,
    Ascii,
    Console,
};

pub const GraphicsOptions = struct {
    GRAPHICS_FRAME_WIDTH: u32 = 1920, // set frame width if only GRAPHICS is enabled
    GRAPHICS_FRAME_HEIGHT: u32 = 1080, // set frame height if only GRAPHICS is enabled
    GRAPHICS_BACKGROUND_COLOR: u32 = 0x000000, // set background color; black background (default) = 0x000000, white background = 0xFFFFFF
    GRAPHICS_TRANSPARENCY: f32 = 0.7, // optional: comment/uncomment this line to disable/enable semi-transparent rendering (looks better but reduces framerate), number represents transparency (equal to 1-opacity) (default: 0.7f)
    GRAPHICS_U_MAX: f32 = 0.25, // maximum velocity for velocity coloring in units of LBM lattice speed of sound (c=1/sqrt(3)) (default: 0.25f)
    GRAPHICS_Q_CRITERION: f32 = 0.0001, // Q-criterion value for Q-criterion isosurface visualization (default: 0.0001f)
    GRAPHICS_F_MAX: f32 = 0.002, // maximum force in LBM units for visualization of forces on solid boundaries if VOLUME_FORCE is enabled and lbm.calculate_force_on_boundaries(); is called (default: 0.002f)
    GRAPHICS_STREAMLINE_SPARSE: u32 = 4, // set how many streamlines there are every x lattice points
    GRAPHICS_STREAMLINE_LENGTH: u32 = 128, // set maximum length of streamlines
    GRAPHICS_RAYTRACING_TRANSMITTANCE: f32 = 0.25, // transmitted light fraction in raytracing graphics ("0.25f" = 1/4 of light is transmitted and 3/4 is absorbed along longest box side length, "1.0f" = no absorption)
    GRAPHICS_RAYTRACING_COLOR: u32 = 0x005F7F, // absorption color of fluid in raytracing graphics
    pub fn init() GraphicsOptions {
        return GraphicsOptions{};
    }
};

pub const CellType = enum(u8) {
    TYPE_S = 0b00000001, // (stationary or moving) solid boundary
    TYPE_E = 0b00000010, // equilibrium boundary (inflow/outflow)
    TYPE_T = 0b00000100, // temperature boundary
    TYPE_F = 0b00001000, // fluid
    TYPE_I = 0b00010000, // interface
    TYPE_G = 0b00100000, // gas
    TYPE_X = 0b01000000, // reserved type X
    TYPE_Y = 0b10000000, // reserved type Y
};

pub const Visualization_Mode = enum(u8) {
    VIS_FLAG_LATTICE = 0b00000001,
    VIS_FLAG_SURFACE = 0b00000010,
    VIS_FIELD = 0b00000100,
    VIS_STREAMLINES = 0b00001000,
    VIS_Q_CRITERION = 0b00010000,
    VIS_PHI_RASTERIZE = 0b00100000,
    VIS_PHI_RAYTRACE = 0b01000000,
    VIS_PARTICLES = 0b10000000,
};

pub const FPXX = enum {
    ushort,
    float,
};

pub const Configuration = struct {
    velocity: VelocitySet,
    relax: RelaxationTime,
    fpc: ?FloatingPointCompresson,
    fpx: FPXX = FPXX.float,
    graphics: ?GraphicsMode,
    goptions: ?GraphicsOptions,
    options: GlobalOptions,
    visuals: ?Visualization_Mode,

    pub fn defaults() Configuration {
        return Configuration{ .velocity = VelocitySet.D3Q19, .relax = RelaxationTime.SRT, .fpc = null, .fpx = FPXX.float, .graphics = null, .goptions = null, .options = GlobalOptions.init(), .visuals = null };
    }

    pub fn setFloatingPointCompression(self: *Configuration, fpc: FloatingPointCompresson) void {
        self.fpc = fpc;
        self.fpx = FPXX.ushort;
    }

    pub fn setBenchmark(self: *Configuration) void {
        self.options = GlobalOptions{
            .UPDATE_FIELDS = false,
            .VOLUME_FORCE = false,
            .FORCE_FIELD = false,
            .MOVING_BOUNDARIES = false,
            .EQUILIBRIUM_BOUNDARIES = false,
            .SURFACE = false,
            .TEMPERATURE = false,
            .SUBGRID = false,
            .PARTICLES = false,
            .INTERACTIVE_GRAPHICS = false,
            .INTERACTIVE_GRAPHICS_ASCII = false,
            .GRAPHICS = false,
        };
    }

    pub fn setSurface(self: *Configuration) void {
        self.options.SURFACE = true;
        self.options.UPDATE_FIELDS = true;
    }
    pub fn setTemperature(self: *Configuration) void {
        self.options.TEMPERATURE = true;
        self.options.VOLUME_FORCE = true;
    }
    pub fn setParticles(self: *Configuration) void {
        self.options.PARTICLES = true;
        self.options.UPDATE_FIELDS = true;
    }

    pub fn setGraphicsMode(self: *Configuration, mode: GraphicsMode) void {
        self.graphics = mode;
        self.options.UPDATE_FIELDS = true;
        if (!self.goptions) {
            self.goptions = GraphicsOptions.init();
        }
    }
};
