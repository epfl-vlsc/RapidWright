package ch.epfl.vlsc;

import java.util.ArrayList;
import java.util.HashMap;

import com.xilinx.rapidwright.bitstream.Bitstream;
import com.xilinx.rapidwright.bitstream.ConfigArray;
import com.xilinx.rapidwright.design.Cell;
import com.xilinx.rapidwright.design.Design;
import com.xilinx.rapidwright.design.tools.LUTTools;

public class EditBitstream {
  public static void main(String[] args) {
    // EditBitstream <bitFileIn> <dcpFileIn> <dcpFileOut>
    assert args.length == 4;
    String dcpFileIn = args[0];
    String bitFileIn = args[1];
    String dcpFileOut = args[2];
    String bitFileOut = args[3];

    Design design = Design.readCheckpoint(dcpFileIn);

    ArrayList<String> luts = new ArrayList<>();
    luts.add("lut4_gen[0].lut4_inst");
    luts.add("lut4_gen[1].lut4_inst");
    luts.add("lut4_gen[2].lut4_inst");
    luts.add("lut4_gen[3].lut4_inst");

    HashMap<String, Cell> cells = new HashMap<>();
    for (String lutName : luts) {
      Cell cell = design.getCell(lutName);
      cells.put(lutName, cell);

      System.out.println(cell);
      System.out.println("  before = " + cell.getProperty(LUTTools.LUT_INIT));

      LUTTools.configureLUT(cell, "O = I0 & I1 & I2 & I3");
      System.out.println("   after = " + cell.getProperty(LUTTools.LUT_INIT));
    }

    Bitstream bitstream = Bitstream.readBitstream(bitFileIn);
    ConfigArray configArray = bitstream.configureArray();
    configArray.updateUserStateBits(cells.values().toArray(new Cell[0]));
    bitstream.updatePacketsFromConfigArray();

    design.writeCheckpoint(dcpFileOut);
    bitstream.writeBitstream(bitFileOut);
  }
}
