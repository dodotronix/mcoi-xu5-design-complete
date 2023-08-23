# MCOI XU5 complete design


# IMPORTANT NOTES
* If we want to use the si5338b-b-gmr with the onboard oscilator on the PE1 we
  need to use just the capacitors c1606 and c1607 and unmount the c1604 and
  c1605

## GBT
* The gbt works the instance PatternSearch shows status LOCKED 
* If you don't get the status LOCKED check the the 120MHz (MGT_REFCLK) and
  40MHz (FRAMECLK_40MHZ), that their ratio is exactly 3
* if the above does not work, try to shift the 40MHz clock about bit less then
  half a periode
* The simulation of GBT in Vivado xsim does not work with following case state:  

```vhdl

when e1_read   => readAddress := readAddress + 1;
                  if readAddress = 1 then  -- Ready after one full read to be sure that all register contains true data
                     READY_O     <= '1';
                  end if;
```

The IF condition has to be modified as follows:

```vhdl

when e1_read   => readAddress := readAddress + 1;
                  if std_logic_Vector(to_unsigned(readAddress, 3)) = "001" then  -- Ready after one full read to be sure that all register contains true data
                     READY_O     <= '1';
                  end if;
```

* In case the bit slip does not shift the data in the whole range from 0 - 40th
  bit, you probably forgot to set bitslip boundary correctly. it has to be set
  to 4 bytes.
