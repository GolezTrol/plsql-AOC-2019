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

end AOC_2019;
/
