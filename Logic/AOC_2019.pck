create or replace package AOC_2019 is

  function FuzzyListToInts(
    p_List in clob)
  return tt_Integer;
  
  function D1_1_CalcFuel(
    p_Mass number) 
  return number;

  function D1_2_CalcFuel(
    p_Mass number) 
  return number;
  
  function D2_1_IntcodeMemDump(
    p_Intcode varchar2)
  return varchar2;

  function D2_1_RunIntcode(
    p_Intcode varchar2) 
  return int;
  
  function D2_1_RunIntcodeNV(
    p_Intcode varchar2,
    p_Noun int, 
    p_Verb int)
  return int;
  
  function D2_1_RunIntcodeNV2(
    p_Intcode varchar2,
    p_Outcome int)
  return int;
  
end AOC_2019;
/
create or replace package body AOC_2019 is

  /*
    This table function accepts a clob with a fuzzy list of numbers that are separated by anything but numbers.
    Any range of 1 or more non-numerical characters is considered a single separator.
    This function is especially useful for sanitizing input that is read from external sources, especially
    table/column data or manually typed lists that may be comma, tab, space, newline or whatever separated.
  */
  function FuzzyListToInts(
    p_List in clob)
  return tt_Integer 
  is  
    l_Result tt_Integer;
  begin
    select
      to_number(trim(regexp_substr(csv, '[^,]+', 1, level)))
    bulk collect into
      l_Result
    from
      (
        select
          trim(',' from regexp_replace(P_LIST, '[^[:digit:]]+', ',')) as csv
        from
          dual
      )
      connect by level <= regexp_count(csv, ',', 1) + 1;
 
    return l_Result;
  end;

  function D1_1_CalcFuel(
    p_Mass number) 
  return number 
  is
  begin
    -- (mass divided by 3, rounded down, minus 2
    return trunc(p_Mass / 3) - 2;
  end;

  function D1_2_CalcFuel(
    p_Mass number) 
  return number 
  is
    v_Mass number := p_Mass;
    v_Total number := 0;
  begin
    loop
      v_Mass := D1_1_CalcFuel(v_Mass);
    exit when v_Mass <= 0;
      v_Total := v_Total + v_Mass;
    end loop;
    return v_Total;
  end;
  
  procedure D2_1_IntCodeCPU(p_Memory in out tt_Integer)
  is
    v_Pointer int := 0;
    v_Opcode int := 0;
    
    function ReadAddr(p_Parameter int) return int is
    begin
      return p_Memory(p_Memory(v_Pointer+p_Parameter+1)+1);
    end;

    procedure WriteAddr(p_Parameter int, p_Value int) is
      v_Addr int;
    begin
      v_Addr := p_Memory(v_Pointer+p_Parameter+1)+1;
      if v_Addr > p_Memory.count then
        p_Memory.Extend(v_Addr - p_Memory.Count);
      end if;

      p_Memory(v_Addr) := p_Value;
    end;
    
  begin
    loop
      -- Read opcode
      v_Opcode := p_Memory(v_Pointer+1);
      exit when v_Opcode = 99 /* Exit */;

      -- Execute
      case v_Opcode
        when 1 /* Add */ then 
          WriteAddr(3, ReadAddr(1)+ReadAddr(2));
          v_Pointer := v_Pointer + 4;
        when 2 /* Mul */ then 
          WriteAddr(3, ReadAddr(1)*ReadAddr(2));
          v_Pointer := v_Pointer + 4;
        when 99 /* Exit */ then
          exit;
      else 
        null;
      end case;
    end loop;

  end;
  
  function D2_1_IntcodeMemDump(
    p_Intcode varchar2) 
  return varchar2
  is
    v_Memory tt_Integer;
    v_Result varchar2(4000);
  begin
    v_Memory := FuzzyListToInts(p_Intcode);

    D2_1_IntCodeCPU(v_Memory);
    
    -- Construct result string
    for i in 1 .. v_Memory.count loop
      v_Result := v_Result || v_Memory(i) || ',';
    end loop;
    return rtrim(v_Result, ',');
  end;

  function D2_1_RunIntcode(
    p_Intcode varchar2) 
  return int
  is
    v_Memory tt_Integer;
  begin
    v_Memory := FuzzyListToInts(p_Intcode);

    D2_1_IntCodeCPU(v_Memory);
    
    return v_Memory(1);
  end;
  
  function D2_1_RunIntcodeNV(
    p_Intcode varchar2,
    p_Noun int, 
    p_Verb int) 
  return int
  is
    v_Memory tt_Integer;
  begin
    v_Memory := FuzzyListToInts(p_Intcode);
    v_Memory(2) := p_Noun;
    v_Memory(3) := p_Verb;

    D2_1_IntCodeCPU(v_Memory);
    
    return v_Memory(1);
  end;

  function D2_1_RunIntcodeNV2(
    p_Intcode varchar2,
    p_Outcome int) 
  return int
  is
    v_Program tt_Integer;
    v_Memory tt_Integer;
    v_Noun int; 
    v_Verb int;
  begin
    v_Program := FuzzyListToInts(p_Intcode);
    for v_Noun in 0..99 loop
      for v_Verb in 0..99 loop
        v_Memory := v_Program;
        v_Memory(2) := v_Noun;
        v_Memory(3) := v_Verb;

        D2_1_IntCodeCPU(v_Memory);
        
        if v_Memory(1) = p_Outcome then
          return 100 * v_Noun + v_Verb;
        end if;
      end loop;
    end loop;

    
    return null;
  end;
  
end AOC_2019;
/
