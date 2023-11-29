-------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.11.2023 22:18:34
-- Design Name: 
-- Module Name: vga_resolucion - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.numeric_std.ALL;
library work;

entity vga_800x600 is
Port ( clk, clr : in STD_LOGIC;
hsync : out STD_LOGIC;
vsync : out STD_LOGIC;
hc : out STD_LOGIC_VECTOR (9 downto 0);
vc : out STD_LOGIC_VECTOR (9 downto 0);
vidon : out STD_LOGIC);
end vga_800x600;

architecture Behavioral of vga_800x600 is
-- horizontal timig --
constant hbp : std_logic_vector (9 downto 0) := "0011001000"; --hbp = sp+bp= 72+128=200
constant hfp : std_logic_vector (9 downto 0) := "1111101000"; --hfp = hbp+hv = 200+800=1000 
constant hpixels : std_logic_vector (9 downto 0) := "1111000100"; --toda la linea completa lleva 964 pixeles


-- vertical timig --
constant vbp : std_logic_vector (9 downto 0) := "0000011000"; --vbp= sp+bp= 22+2=24
constant vfp : std_logic_vector (9 downto 0) := "1001110000"; --vfp= vbp+vv= 24+600=624
constant vlines : std_logic_vector (9 downto 0) := "1010000001";--lineas verticales 641

 
signal hcs, vcs : std_logic_vector (9 downto 0); -- horizontal & vertical counters
signal vsenable : std_logic; -- vertical counter enable
begin

-- horizontal counter syncronization signal
process (clk, clr)
begin
if (clr = '1') then
hcs <= "0000000000";
elsif (rising_edge(clk)) then
if (hcs = hpixels - 1) then -- counter has reached end of count 
hcs <= "0000000000"; -- reset
vsenable <= '1'; -- set flag to go vertical counter
else
hcs <= hcs + 1; -- increment horizontal counter
vsenable <= '0'; -- clear vertical counter flag
end if ;
end if;
end process;
hsync <= '0' when (hcs < 96) else '1'; -- SP=0 when hc<128 pixels
-- vertical counter syncronization signal
process (clk, clr, vsenable)
begin
if (clr = '1') then
vcs <= "0000000000";
elsif ((rising_edge (clk)) and (vsenable = '1')) then
if (vcs = vlines - 1) then -- counter has reached the end of count ?
vcs <= "0000000000"; -- reset
else
vcs <= vcs + 1; -- increment vertical counter
end if;
end if;
end process;
vsync <= '0' when (vcs < 2) else '1' ; -- SP=0 when vc<2 lines
vidon <= '1' when (((hcs < hfp) and (hcs >= hbp)) and ((vcs < vfp) and (vcs >= vbp))) else '0'; -- set video on when visible area

-- horizontal and vertical counters update
hc <= hcs;
vc <= vcs ;
end Behavioral;