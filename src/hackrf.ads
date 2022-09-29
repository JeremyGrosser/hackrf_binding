--
--  Copyright (C) 2022 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
private with libhackrf;
with Interfaces;

package HackRF is
   HackRF_Exception : exception;

   subtype Hertz is Long_Float range 0.0 .. Long_Float'Last;
   type Decibels is new Integer;

   subtype RF_Gain is Decibels range 0 .. 14
      with Dynamic_Predicate => RF_Gain mod 14 = 0;
   subtype LNA_Gain is Decibels range 0 .. 40
      with Dynamic_Predicate => LNA_Gain mod 8 = 0;
   subtype VGA_Gain is Decibels range 0 .. 62
      with Dynamic_Predicate => VGA_Gain mod 2 = 0;

   type Device is tagged private;

   function Open
      return Device;
   --  TODO: Support multiple devices

   procedure Set_Sample_Rate
      (This : Device;
       Rate : Hertz);

   procedure Set_RF_Gain
      (This : Device;
       Gain : RF_Gain);

   procedure Set_LNA_Gain
      (This : Device;
       Gain : LNA_Gain);

   procedure Set_VGA_Gain
      (This : Device;
       Gain : VGA_Gain);

   procedure Set_Frequency
      (This      : Device;
       Frequency : Hertz);

   type Sample is record
      I, Q : Interfaces.Integer_8;
   end record
      with Size => 16;

   type Sample_Array is array (Positive range <>) of Sample
      with Component_Size => 16;

   type Receive_Callback is access procedure
      (Data : Sample_Array);

   procedure Start_Receive
      (This     : in out Device;
       Callback : not null Receive_Callback);

   procedure Stop_Receive
      (This : Device);

   --  TODO: Start_Transmit

   procedure Close
      (This : Device);

   procedure Destroy;
   --  TODO: Finalization?

private

   type Device is tagged record
      Dev      : access libhackrf.hackrf_device := null;
      Callback : Receive_Callback := null;
   end record;

end HackRF;
