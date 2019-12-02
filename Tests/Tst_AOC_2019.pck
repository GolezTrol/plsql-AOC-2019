create or replace package Tst_AOC_2019 is
  -- %suite(Advent of Code 2019, day 1
  -- %suitepath(AOC.2019)
  
  -- %context(Utilities)
    
    -- %test (Fuzzy splitter splits on any sequence of non-numerical characters)
    procedure Test_Fuzzy_Splitter;

  -- %endcontext
  
  -- %context(Day 1)
  
    -- %test (Correctly calculating the fuel needed for a given mass)
    procedure Test_D1_1_GasForMass;
    
    -- %test (Include the gas to transport the gas)
    procedure Test_D1_2_GasForGas;

  -- %endcontext
 
end Tst_AOC_2019;
/
create or replace package body Tst_AOC_2019 is

  procedure Test_Fuzzy_Splitter 
  is
    l_Expected tt_Integer := tt_Integer();
  begin
    l_Expected.EXTEND(4);
    l_Expected(1) := 56;
    l_Expected(2) := 2;
    l_Expected(3) := 999;
    l_Expected(4) := 57;
    
    ut.expect(anydata.ConvertCollection(AOC_2019.FuzzyListToInts('  56, 2.999,57')))
      .to_equal(anydata.ConvertCollection(l_Expected));
  end;

  -- For a mass of 12, divide by 3 and round down to get 4, then subtract 2 to get 2.
  -- For a mass of 14, dividing by 3 and rounding down still yields 4, so the fuel required is also 2.
  -- For a mass of 1969, the fuel required is 654.
  -- for a mass of 100756, the fuel required is 33583.
  procedure Test_D1_1_GasForMass is
  begin
    ut.expect(AOC_2019.D1_1_CalcFuel(12)).to_equal(2);
    ut.expect(AOC_2019.D1_1_CalcFuel(14)).to_equal(2);
    ut.expect(AOC_2019.D1_1_CalcFuel(1969)).to_equal(654);
    ut.expect(AOC_2019.D1_1_CalcFuel(100756)).to_equal(33583);
  end;
  
  -- A module of mass 14 requires 2 fuel. This fuel requires no further fuel (2 divided by 3 and 
  -- rounded down is 0, which would call for a negative fuel), so the total fuel required is still just 2.
  -- At first, a module of mass 1969 requires 654 fuel. Then, this fuel requires 216 more fuel (654 / 3 - 2). 
  -- 216 then requires 70 more fuel, which requires 21 fuel, which requires 5 fuel, which requires no further fuel. 
  -- So, the total fuel required for a module of mass 1969 is 654 + 216 + 70 + 21 + 5 = 966.
  -- The fuel required by a module of mass 100756 and its fuel is: 
  -- 33583 + 11192 + 3728 + 1240 + 411 + 135 + 43 + 12 + 2 = 50346.
  procedure Test_D1_2_GasForGas is
  begin
    ut.expect(AOC_2019.D1_2_CalcFuel(14)).to_equal(2);
    ut.expect(AOC_2019.D1_2_CalcFuel(1969)).to_equal(966);
    ut.expect(AOC_2019.D1_2_CalcFuel(100756)).to_equal(50346);
  end;

end Tst_AOC_2019;
/
