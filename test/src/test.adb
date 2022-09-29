--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Ada.Real_Time; use Ada.Real_Time;
with Ada.Text_IO; use Ada.Text_IO;
with HackRF;

procedure Test is

   package FIO is new Ada.Text_IO.Float_IO (Float);

   Count : Natural := 0;
   Limit : constant := 16_000_000;

   Start    : constant Time := Clock;
   Elapsed  : Duration := 0.0;

   procedure Callback
      (Samples : HackRF.Sample_Array)
   is
   begin
      if Count < Limit then
         Count := Count + Samples'Length;
      elsif Elapsed = 0.0 then
         Elapsed := To_Duration (Clock - Start);
      end if;
   end Callback;

   MSamples_Per_Second : Float;
   Dev      : HackRF.Device := HackRF.Open;
begin
   Dev.Set_Sample_Rate (16.0e6);
   Dev.Set_RF_Gain (0);
   Dev.Set_LNA_Gain (8);
   Dev.Set_VGA_Gain (20);
   Dev.Set_Frequency (2.402e6);
   Dev.Start_Receive (Callback'Unrestricted_Access);
   loop
      exit when Elapsed /= 0.0;
      delay 0.001;
   end loop;

   Dev.Stop_Receive;
   Dev.Close;
   HackRF.Destroy;

   Put ("Received");
   Put (Count'Image);
   Put (" samples in ");
   FIO.Put (Float (Elapsed), Fore => 1, Aft => 3, Exp => 0);
   Put (" seconds");
   New_Line;

   MSamples_Per_Second := (Float (Count) / Float (Elapsed)) / 1.0e6;
   FIO.Put (MSamples_Per_Second, Fore => 2, Aft => 3, Exp => 0);
   Put (" megasamples per second");
   New_Line;
end Test;
