@0x9d262c6ba6512325;
using Java = import "/capnp/java.capnp";
using Dir = import "LogicalNetlist.capnp";
$Java.package("com.xilinx.rapidwright.interchange");
$Java.outerClassname("DeviceResources");

using StringIdx = UInt32;
using SiteTypeIdx = UInt32;
using BELPinIdx = UInt32;
using WireIdx = UInt32;
using WireIDInTileType = UInt32; # ID in Tile Type
using SitePinIdx = UInt32;
using TileTypeSiteTypeIdx = UInt32;

struct Device {

  name            @0 : Text;
  strList         @1 : List(Text);
  siteTypeList    @2 : List(SiteType);
  tileTypeList    @3 : List(TileType);
  tileList        @4 : List(Tile);
  wires           @5 : List(Wire);
  nodes           @6 : List(Node);
  primLibs        @7 : Dir.Netlist; # Netlist libraries of Unisim primitives and macros
  exceptionMap    @8 : List(PrimToMacroExpansion); # Prims to macros expand w/same name, except these
  cellBelMap      @9 : List(CellBelMapping);
  cellInversions @10 : Void;
  packages       @11 : List(Package);

  #######################################
  # Placement definition objects
  #######################################
  struct SiteType {
    name         @0 : StringIdx;
    pins         @1 : List(SitePin);
    lastInput    @2 : UInt32; # Index of the last input pin
    bels         @3 : List(BEL);
    belPins      @4 : List(BELPin); # All BEL Pins in site type
    sitePIPs     @5 : List(SitePIP);
    siteWires    @6 : List(SiteWire);
    altSiteTypes @7 : List(SiteTypeIdx);
  }

  # Maps site pins from alternative site types to the parent primary site pins
  struct ParentPins {
    # pins[0] is the mapping of the siteTypeList[altSiteType].pins[0] to the
    # primary site pin index.
    #
    # To determine the tile wire for a alternative site type, first get the
    # site pin index for primary site, then use primaryPinsToTileWires.
    pins  @0 : List(SitePinIdx);
  }

  struct SiteTypeInTileType {
    primaryType @0 : SiteTypeIdx;

    # primaryPinsToTileWires[0] is the tile wire that matches
    # siteTypeList[primaryType].pins[0], etc.
    primaryPinsToTileWires @1 : List(StringIdx);

    # altPinsToPrimaryPins[0] is the mapping for
    # siteTypeList[primaryType].altSiteTypes[0], etc.
    altPinsToPrimaryPins @2 : List(ParentPins);
  }

  struct TileType {
    name       @0 : StringIdx;
    siteTypes  @1 : List(SiteTypeInTileType);
    wires      @2 : List(StringIdx);
    pips       @3 : List(PIP);
  }

  #######################################
  # Placement instance objects
  #######################################
  struct BEL {
    name      @0 : StringIdx;
    type      @1 : StringIdx;
    pins      @2 : List(BELPinIdx);
    category  @3 : BELCategory; # This would be BELClass/class, but conflicts with Java language
  }

  enum BELCategory {
    logic    @0;
    routing  @1;
    sitePort @2;
  }

  struct Site {
    name      @0 : StringIdx;
    type      @1 : TileTypeSiteTypeIdx; # Index into TileType.siteTypes
  }

  struct Tile {
    name       @0 : StringIdx;
    type       @1 : StringIdx;
    sites      @2 : List(Site);
    row        @3 : UInt16;
    col        @4 : UInt16;
    tilePatIdx @5 : UInt32;
  }

  ######################################
  # Intra-site routing resources
  ######################################
  struct BELPin {
    name   @0 : StringIdx;
    dir    @1 : Dir.Netlist.Direction;
    bel    @2 : StringIdx;
  }

  struct SiteWire {
    name   @0 : StringIdx;
    pins   @1 : List(BELPinIdx);
  }

  struct SitePIP {
    inpin  @0 : BELPinIdx;
    outpin @1 : BELPinIdx;
  }

  struct SitePin {
    name     @0 : StringIdx;
    dir      @1 : Dir.Netlist.Direction;
    belpin   @2 : BELPinIdx;
  }


  ######################################
  # Inter-site routing resources
  ######################################
  struct Wire {
    tile      @0 : StringIdx;
    wire      @1 : StringIdx;
  }

  struct Node {
    wires    @0 : List(WireIdx);
  }

  struct PIP {
    wire0        @0 : WireIDInTileType;
    wire1        @1 : WireIDInTileType;
    directional  @2 : Bool;
    buffered20   @3 : Bool;
    buffered21   @4 : Bool;
    union {
      conventional @5 : Void;
      pseudoCells  @6 : List(PseudoCell);
    }
  }

  struct PseudoCell {
    bel          @0 : StringIdx;
    pins         @1 : List(StringIdx);
  }

  ######################################
  # Macro expansion exception map for
  # primitives that don't expand to a
  # macro of the same name.
  ######################################
  struct PrimToMacroExpansion {
    primName  @0 : StringIdx;
    macroName @1 : StringIdx;
  }

  # Cell <-> BEL and Cell pin <-> BEL Pin mapping
  struct CellBelMapping {
    cell          @0 : StringIdx;
    commonPins    @1 : List(CommonCellBelPinMaps);
    parameterPins @2 : List(ParameterCellBelPinMaps);
  }

  # Map one cell pin to one BEL pin.
  # Note: There may be more than one BEL pin mapped to one cell pin.
  struct CellBelPinEntry {
    cellPin @0 : StringIdx;
    belPin  @1 : StringIdx;
  }

  # Specifies BELs located in a specific site type.
  struct SiteTypeBelEntry {
    siteType @0 : StringIdx;
    bels     @1 : List(StringIdx);
  }

  # This is the portion of Cell <-> BEL pin mapping that is common across all
  # parameter settings for a specific site type and BELs within that site
  # type.
  struct CommonCellBelPinMaps {
    siteTypes @0 : List(SiteTypeBelEntry);
    pins      @1 : List(CellBelPinEntry);
  }

  # This is the portion of the Cell <-> BEL pin mapping that is parameter
  # specific.
  struct ParameterSiteTypeBelEntry {
    bel       @0 : StringIdx;
    siteType  @1 : StringIdx;
    parameter @2 : Dir.Netlist.PropertyMap.Entry;
  }

  struct ParameterCellBelPinMaps {
    parametersSiteTypes @0 : List(ParameterSiteTypeBelEntry);
    pins                @1 : List(CellBelPinEntry);
  }

  struct Package {
    struct PackagePin {
        packagePin @0 : StringIdx;
        site : union {
            site       @1 : StringIdx;
            noSite     @2 : Void;
        }
        bel : union {
            bel        @3 : StringIdx;
            noBel      @4 : Void;
        }
    }

    struct Grade {
        name             @0 : StringIdx;
        speedGrade       @1 : StringIdx;
        temperatureGrade @2 : StringIdx;
    }

    name        @0 : StringIdx;
    packagePins @1 : List(PackagePin);
    grades      @2 : List(Grade);
  }
}
