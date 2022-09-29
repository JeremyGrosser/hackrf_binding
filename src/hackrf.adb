--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
with Interfaces.C.Strings; use Interfaces.C.Strings;
with Interfaces.C;         use Interfaces.C;
with Interfaces;

package body HackRF is
   use libhackrf;

   function RX_Callback
      (arg1 : access libhackrf.hackrf_transfer)
      return Interfaces.C.int
      with Convention => C;

   function Open
      return Device
   is
      Err : hackrf_error;
      D   : aliased Device with Volatile;
   begin
      Err := hackrf_open (D.Dev'Address);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
      return D;
   end Open;

   procedure Set_Sample_Rate
      (This : Device;
       Rate : Hertz)
   is
      Err : hackrf_error;
   begin
      Err := hackrf_set_sample_rate (This.Dev, double (Rate));
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Set_Sample_Rate;

   procedure Set_RF_Gain
      (This : Device;
       Gain : RF_Gain)
   is
      Err : hackrf_error;
      Enable : constant Interfaces.Unsigned_8 := (if Gain > 0 then 1 else 0);
   begin
      Err := hackrf_set_amp_enable (This.Dev, Enable);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Set_RF_Gain;

   procedure Set_LNA_Gain
      (This : Device;
       Gain : LNA_Gain)
   is
      Err : hackrf_error;
   begin
      Err := hackrf_set_lna_gain (This.Dev, Interfaces.Unsigned_32 (Gain));
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Set_LNA_Gain;

   procedure Set_VGA_Gain
      (This : Device;
       Gain : VGA_Gain)
   is
      Err : hackrf_error;
   begin
      Err := hackrf_set_vga_gain (This.Dev, Interfaces.Unsigned_32 (Gain));
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Set_VGA_Gain;

   procedure Set_Frequency
      (This      : Device;
       Frequency : Hertz)
   is
      use Interfaces;
      Err : hackrf_error;
      F   : constant Unsigned_64 := Unsigned_64 (Integer (Frequency));
   begin
      Err := hackrf_set_freq (This.Dev, F);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Set_Frequency;

   function RX_Callback
      (arg1 : access hackrf_transfer)
      return int
   is
      This   : Device
         with Import, Address => arg1.rx_ctx;
      Length : constant Natural := Natural (arg1.valid_length);
      Valid  : constant Sample_Array (1 .. Length / 2)
         with Import, Address => arg1.buffer'Address;
   begin
      if This.Callback = null then
         raise HackRF_Exception with "RX_Callback called before Start_Receive";
      end if;
      This.Callback (Valid);
      return 0;
   end RX_Callback;

   procedure Start_Receive
      (This     : in out Device;
       Callback : not null Receive_Callback)
   is
      Err : hackrf_error;
   begin
      This.Callback := Callback;
      Err := hackrf_start_rx (This.Dev, RX_Callback'Access, This'Address);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Start_Receive;

   procedure Stop_Receive
      (This : Device)
   is
      Err : hackrf_error;
   begin
      Err := hackrf_stop_rx (This.Dev);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Stop_Receive;

   procedure Close
      (This : Device)
   is
      Err : hackrf_error;
   begin
      Err := hackrf_close (This.Dev);
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Close;

   procedure Destroy is
      Err : hackrf_error;
   begin
      Err := hackrf_exit;
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end Destroy;

begin
   declare
      Err : hackrf_error;
   begin
      Err := hackrf_init;
      if Err /= HACKRF_SUCCESS then
         raise HackRF_Exception with Value (hackrf_error_name (Err));
      end if;
   end;
end HackRF;
