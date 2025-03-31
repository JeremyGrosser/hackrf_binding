--
--  Copyright (C) 2025 Jeremy Grosser <jeremy@synack.me>
--
--  SPDX-License-Identifier: BSD-3-Clause
--
pragma Ada_2012;

pragma Style_Checks (Off);
pragma Warnings (Off, "-gnatwu");

with Interfaces.C; use Interfaces.C;
with Interfaces;
with System;
with Interfaces.C.Extensions;
with Interfaces.C.Strings;

package libhackrf is

   SAMPLES_PER_BLOCK : constant := 8192;  --  /usr/local/include/libhackrf/hackrf.h:512

   BYTES_PER_BLOCK : constant := 16384;  --  /usr/local/include/libhackrf/hackrf.h:518

   MAX_SWEEP_RANGES : constant := 10;  --  /usr/local/include/libhackrf/hackrf.h:524

   HACKRF_OPERACAKE_ADDRESS_INVALID : constant := 16#FF#;  --  /usr/local/include/libhackrf/hackrf.h:530

   HACKRF_OPERACAKE_MAX_BOARDS : constant := 8;  --  /usr/local/include/libhackrf/hackrf.h:536

   HACKRF_OPERACAKE_MAX_DWELL_TIMES : constant := 16;  --  /usr/local/include/libhackrf/hackrf.h:542

   HACKRF_OPERACAKE_MAX_FREQ_RANGES : constant := 8;  --  /usr/local/include/libhackrf/hackrf.h:548

   HACKRF_BOARD_REV_GSG : constant := (16#80#);  --  /usr/local/include/libhackrf/hackrf.h:619

   HACKRF_PLATFORM_JAWBREAKER : constant := (2 ** 0);  --  /usr/local/include/libhackrf/hackrf.h:625

   HACKRF_PLATFORM_HACKRF1_OG : constant := (2 ** 1);  --  /usr/local/include/libhackrf/hackrf.h:630

   HACKRF_PLATFORM_RAD1O : constant := (2 ** 2);  --  /usr/local/include/libhackrf/hackrf.h:635

   HACKRF_PLATFORM_HACKRF1_R9 : constant := (2 ** 3);  --  /usr/local/include/libhackrf/hackrf.h:640
   --  unsupported macro: BOARD_ID_HACKRF_ONE (BOARD_ID_HACKRF1_OG)
   --  unsupported macro: BOARD_ID_INVALID (BOARD_ID_UNDETECTED)

   subtype hackrf_error is int;
   HACKRF_SUCCESS : constant hackrf_error := 0;
   HACKRF_TRUE : constant hackrf_error := 1;
   HACKRF_ERROR_INVALID_PARAM : constant hackrf_error := -2;
   HACKRF_ERROR_NOT_FOUND : constant hackrf_error := -5;
   HACKRF_ERROR_BUSY : constant hackrf_error := -6;
   HACKRF_ERROR_NO_MEM : constant hackrf_error := -11;
   HACKRF_ERROR_LIBUSB : constant hackrf_error := -1000;
   HACKRF_ERROR_THREAD : constant hackrf_error := -1001;
   HACKRF_ERROR_STREAMING_THREAD_ERR : constant hackrf_error := -1002;
   HACKRF_ERROR_STREAMING_STOPPED : constant hackrf_error := -1003;
   HACKRF_ERROR_STREAMING_EXIT_CALLED : constant hackrf_error := -1004;
   HACKRF_ERROR_USB_API_VERSION : constant hackrf_error := -1005;
   HACKRF_ERROR_NOT_LAST_DEVICE : constant hackrf_error := -2000;
   HACKRF_ERROR_OTHER : constant hackrf_error := -9999;  -- /usr/local/include/libhackrf/hackrf.h:556

   subtype hackrf_board_id is unsigned;
   BOARD_ID_JELLYBEAN : constant hackrf_board_id := 0;
   BOARD_ID_JAWBREAKER : constant hackrf_board_id := 1;
   BOARD_ID_HACKRF1_OG : constant hackrf_board_id := 2;
   BOARD_ID_RAD1O : constant hackrf_board_id := 3;
   BOARD_ID_HACKRF1_R9 : constant hackrf_board_id := 4;
   BOARD_ID_UNRECOGNIZED : constant hackrf_board_id := 254;
   BOARD_ID_UNDETECTED : constant hackrf_board_id := 255;  -- /usr/local/include/libhackrf/hackrf.h:648

   subtype hackrf_board_rev is unsigned;
   BOARD_REV_HACKRF1_OLD : constant hackrf_board_rev := 0;
   BOARD_REV_HACKRF1_R6 : constant hackrf_board_rev := 1;
   BOARD_REV_HACKRF1_R7 : constant hackrf_board_rev := 2;
   BOARD_REV_HACKRF1_R8 : constant hackrf_board_rev := 3;
   BOARD_REV_HACKRF1_R9 : constant hackrf_board_rev := 4;
   BOARD_REV_HACKRF1_R10 : constant hackrf_board_rev := 5;
   BOARD_REV_GSG_HACKRF1_R6 : constant hackrf_board_rev := 129;
   BOARD_REV_GSG_HACKRF1_R7 : constant hackrf_board_rev := 130;
   BOARD_REV_GSG_HACKRF1_R8 : constant hackrf_board_rev := 131;
   BOARD_REV_GSG_HACKRF1_R9 : constant hackrf_board_rev := 132;
   BOARD_REV_GSG_HACKRF1_R10 : constant hackrf_board_rev := 133;
   BOARD_REV_UNRECOGNIZED : constant hackrf_board_rev := 254;
   BOARD_REV_UNDETECTED : constant hackrf_board_rev := 255;  -- /usr/local/include/libhackrf/hackrf.h:696

   subtype hackrf_usb_board_id is unsigned;
   USB_BOARD_ID_JAWBREAKER : constant hackrf_usb_board_id := 24651;
   USB_BOARD_ID_HACKRF_ONE : constant hackrf_usb_board_id := 24713;
   USB_BOARD_ID_RAD1O : constant hackrf_usb_board_id := 52245;
   USB_BOARD_ID_INVALID : constant hackrf_usb_board_id := 65535;  -- /usr/local/include/libhackrf/hackrf.h:760

   type rf_path_filter is
     (RF_PATH_FILTER_BYPASS,
      RF_PATH_FILTER_LOW_PASS,
      RF_PATH_FILTER_HIGH_PASS)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:786

   type operacake_ports is
     (OPERACAKE_PA1,
      OPERACAKE_PA2,
      OPERACAKE_PA3,
      OPERACAKE_PA4,
      OPERACAKE_PB1,
      OPERACAKE_PB2,
      OPERACAKE_PB3,
      OPERACAKE_PB4)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:805

   type operacake_switching_mode is
     (OPERACAKE_MODE_MANUAL,
      OPERACAKE_MODE_FREQUENCY,
      OPERACAKE_MODE_TIME)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:820

   type sweep_style is
     (LINEAR,
      INTERLEAVED)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:843

   type hackrf_device is null record;   -- incomplete struct

   type hackrf_transfer is record
      device : access hackrf_device;  -- /usr/local/include/libhackrf/hackrf.h:869
      buffer : access Interfaces.Unsigned_8;  -- /usr/local/include/libhackrf/hackrf.h:871
      buffer_length : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:873
      valid_length : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:875
      rx_ctx : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:877
      tx_ctx : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:879
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:880

   type anon_array1231 is array (0 .. 1) of aliased Interfaces.Unsigned_32;
   type anon_array1232 is array (0 .. 3) of aliased Interfaces.Unsigned_32;
   type read_partid_serialno_t is record
      part_id : aliased anon_array1231;  -- /usr/local/include/libhackrf/hackrf.h:890
      serial_no : aliased anon_array1232;  -- /usr/local/include/libhackrf/hackrf.h:894
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:895

   type hackrf_operacake_dwell_time is record
      dwell : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:905
      port : aliased Interfaces.Unsigned_8;  -- /usr/local/include/libhackrf/hackrf.h:909
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:910

   type hackrf_operacake_freq_range is record
      freq_min : aliased Interfaces.Unsigned_16;  -- /usr/local/include/libhackrf/hackrf.h:920
      freq_max : aliased Interfaces.Unsigned_16;  -- /usr/local/include/libhackrf/hackrf.h:924
      port : aliased Interfaces.Unsigned_8;  -- /usr/local/include/libhackrf/hackrf.h:928
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:929

   type hackrf_bool_user_settting is record
      do_update : aliased Extensions.bool;  -- /usr/local/include/libhackrf/hackrf.h:936
      change_on_mode_entry : aliased Extensions.bool;  -- /usr/local/include/libhackrf/hackrf.h:937
      enabled : aliased Extensions.bool;  -- /usr/local/include/libhackrf/hackrf.h:938
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:939

   type hackrf_bias_t_user_settting_req is record
      tx : aliased hackrf_bool_user_settting;  -- /usr/local/include/libhackrf/hackrf.h:948
      rx : aliased hackrf_bool_user_settting;  -- /usr/local/include/libhackrf/hackrf.h:949
      off : aliased hackrf_bool_user_settting;  -- /usr/local/include/libhackrf/hackrf.h:950
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:951

   type hackrf_m0_state is record
      requested_mode : aliased Interfaces.Unsigned_16;  -- /usr/local/include/libhackrf/hackrf.h:959
      request_flag : aliased Interfaces.Unsigned_16;  -- /usr/local/include/libhackrf/hackrf.h:961
      active_mode : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:963
      m0_count : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:965
      m4_count : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:967
      num_shortfalls : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:969
      longest_shortfall : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:971
      shortfall_limit : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:973
      threshold : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:975
      next_mode : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:977
      error : aliased Interfaces.Unsigned_32;  -- /usr/local/include/libhackrf/hackrf.h:979
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:980

   type hackrf_device_list is record
      serial_numbers : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:992
      usb_board_ids : access hackrf_usb_board_id;  -- /usr/local/include/libhackrf/hackrf.h:996
      usb_device_index : access int;  -- /usr/local/include/libhackrf/hackrf.h:1000
      devicecount : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:1005
      usb_devices : System.Address;  -- /usr/local/include/libhackrf/hackrf.h:1010
      usb_devicecount : aliased int;  -- /usr/local/include/libhackrf/hackrf.h:1014
   end record
   with Convention => C_Pass_By_Copy;  -- /usr/local/include/libhackrf/hackrf.h:988

   subtype hackrf_device_list_t is hackrf_device_list;  -- /usr/local/include/libhackrf/hackrf.h:1017

   type hackrf_sample_block_cb_fn is access function (arg1 : access hackrf_transfer) return int
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:1031

   type hackrf_tx_block_complete_cb_fn is access procedure (arg1 : access hackrf_transfer; arg2 : int)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:1039

   type hackrf_flush_cb_fn is access procedure (arg1 : System.Address; arg2 : int)
   with Convention => C;  -- /usr/local/include/libhackrf/hackrf.h:1047

   function hackrf_init return int  -- /usr/local/include/libhackrf/hackrf.h:1060
   with Import => True,
        Convention => C,
        External_Name => "hackrf_init";

   function hackrf_exit return int  -- /usr/local/include/libhackrf/hackrf.h:1069
   with Import => True,
        Convention => C,
        External_Name => "hackrf_exit";

   function hackrf_library_version return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1078
   with Import => True,
        Convention => C,
        External_Name => "hackrf_library_version";

   function hackrf_library_release return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1087
   with Import => True,
        Convention => C,
        External_Name => "hackrf_library_release";

   function hackrf_get_device_list return access hackrf_device_list_t  -- /usr/local/include/libhackrf/hackrf.h:1094
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list";

   function hackrf_device_list_open
     (list : access hackrf_device_list_t;
      idx : int;
      device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1104
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list_open";

   procedure hackrf_device_list_free (list : access hackrf_device_list_t)  -- /usr/local/include/libhackrf/hackrf.h:1114
   with Import => True,
        Convention => C,
        External_Name => "hackrf_device_list_free";

   function hackrf_open (device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1122
   with Import => True,
        Convention => C,
        External_Name => "hackrf_open";

   function hackrf_open_by_serial (desired_serial_number : Interfaces.C.Strings.chars_ptr; device : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1131
   with Import => True,
        Convention => C,
        External_Name => "hackrf_open_by_serial";

   function hackrf_close (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1141
   with Import => True,
        Convention => C,
        External_Name => "hackrf_close";

   function hackrf_start_rx
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      rx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1155
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_rx";

   function hackrf_stop_rx (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1167
   with Import => True,
        Convention => C,
        External_Name => "hackrf_stop_rx";

   function hackrf_start_tx
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      tx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1183
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_tx";

   function hackrf_set_tx_block_complete_callback (device : access hackrf_device; callback : hackrf_tx_block_complete_cb_fn) return int  -- /usr/local/include/libhackrf/hackrf.h:1198
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_tx_block_complete_callback";

   function hackrf_enable_tx_flush
     (device : access hackrf_device;
      callback : hackrf_flush_cb_fn;
      flush_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:1213
   with Import => True,
        Convention => C,
        External_Name => "hackrf_enable_tx_flush";

   function hackrf_stop_tx (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1225
   with Import => True,
        Convention => C,
        External_Name => "hackrf_stop_tx";

   function hackrf_get_m0_state (device : access hackrf_device; value : access hackrf_m0_state) return int  -- /usr/local/include/libhackrf/hackrf.h:1236
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_m0_state";

   function hackrf_set_tx_underrun_limit (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1251
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_tx_underrun_limit";

   function hackrf_set_rx_overrun_limit (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1266
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_rx_overrun_limit";

   function hackrf_is_streaming (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1277
   with Import => True,
        Convention => C,
        External_Name => "hackrf_is_streaming";

   function hackrf_max2837_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1290
   with Import => True,
        Convention => C,
        External_Name => "hackrf_max2837_read";

   function hackrf_max2837_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1306
   with Import => True,
        Convention => C,
        External_Name => "hackrf_max2837_write";

   function hackrf_si5351c_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_16;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1322
   with Import => True,
        Convention => C,
        External_Name => "hackrf_si5351c_read";

   function hackrf_si5351c_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_16;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1338
   with Import => True,
        Convention => C,
        External_Name => "hackrf_si5351c_write";

   function hackrf_set_baseband_filter_bandwidth (device : access hackrf_device; bandwidth_hz : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1356
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_baseband_filter_bandwidth";

   function hackrf_rffc5071_read
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1371
   with Import => True,
        Convention => C,
        External_Name => "hackrf_rffc5071_read";

   function hackrf_rffc5071_write
     (device : access hackrf_device;
      register_number : Interfaces.Unsigned_8;
      value : Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1387
   with Import => True,
        Convention => C,
        External_Name => "hackrf_rffc5071_write";

   function hackrf_spiflash_erase (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1401
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_erase";

   function hackrf_spiflash_write
     (device : access hackrf_device;
      address : Interfaces.Unsigned_32;
      length : Interfaces.Unsigned_16;
      data : access unsigned_char) return int  -- /usr/local/include/libhackrf/hackrf.h:1415
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_write";

   function hackrf_spiflash_read
     (device : access hackrf_device;
      address : Interfaces.Unsigned_32;
      length : Interfaces.Unsigned_16;
      data : access unsigned_char) return int  -- /usr/local/include/libhackrf/hackrf.h:1433
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_read";

   function hackrf_spiflash_status (device : access hackrf_device; data : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1450
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_status";

   function hackrf_spiflash_clear_status (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1462
   with Import => True,
        Convention => C,
        External_Name => "hackrf_spiflash_clear_status";

   function hackrf_cpld_write
     (device : access hackrf_device;
      data : access unsigned_char;
      total_length : unsigned) return int  -- /usr/local/include/libhackrf/hackrf.h:1476
   with Import => True,
        Convention => C,
        External_Name => "hackrf_cpld_write";

   function hackrf_board_id_read (device : access hackrf_device; value : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1492
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_id_read";

   function hackrf_version_string_read
     (device : access hackrf_device;
      version : Interfaces.C.Strings.chars_ptr;
      length : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1504
   with Import => True,
        Convention => C,
        External_Name => "hackrf_version_string_read";

   function hackrf_usb_api_version_read (device : access hackrf_device; version : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1527
   with Import => True,
        Convention => C,
        External_Name => "hackrf_usb_api_version_read";

   function hackrf_set_freq (device : access hackrf_device; freq_hz : Interfaces.Unsigned_64) return int  -- /usr/local/include/libhackrf/hackrf.h:1543
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_freq";

   function hackrf_set_freq_explicit
     (device : access hackrf_device;
      if_freq_hz : Interfaces.Unsigned_64;
      lo_freq_hz : Interfaces.Unsigned_64;
      path : rf_path_filter) return int  -- /usr/local/include/libhackrf/hackrf.h:1557
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_freq_explicit";

   function hackrf_set_sample_rate_manual
     (device : access hackrf_device;
      freq_hz : Interfaces.Unsigned_32;
      divider : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1577
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_sample_rate_manual";

   function hackrf_set_sample_rate (device : access hackrf_device; freq_hz : double) return int  -- /usr/local/include/libhackrf/hackrf.h:1593
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_sample_rate";

   function hackrf_set_amp_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1607
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_amp_enable";

   function hackrf_board_partid_serialno_read (device : access hackrf_device; read_partid_serialno : access read_partid_serialno_t) return int  -- /usr/local/include/libhackrf/hackrf.h:1621
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_partid_serialno_read";

   function hackrf_set_lna_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1635
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_lna_gain";

   function hackrf_set_vga_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1645
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_vga_gain";

   function hackrf_set_txvga_gain (device : access hackrf_device; value : Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:1655
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_txvga_gain";

   function hackrf_set_antenna_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1669
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_antenna_enable";

   function hackrf_error_name (errcode : hackrf_error) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1679
   with Import => True,
        Convention => C,
        External_Name => "hackrf_error_name";

   function hackrf_board_id_name (board_id : hackrf_board_id) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1688
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_id_name";

   function hackrf_board_id_platform (board_id : hackrf_board_id) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:1697
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_id_platform";

   function hackrf_usb_board_id_name (usb_board_id : hackrf_usb_board_id) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1706
   with Import => True,
        Convention => C,
        External_Name => "hackrf_usb_board_id_name";

   function hackrf_filter_path_name (path : rf_path_filter) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:1715
   with Import => True,
        Convention => C,
        External_Name => "hackrf_filter_path_name";

   function hackrf_compute_baseband_filter_bw_round_down_lt (bandwidth_hz : Interfaces.Unsigned_32) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:1726
   with Import => True,
        Convention => C,
        External_Name => "hackrf_compute_baseband_filter_bw_round_down_lt";

   function hackrf_compute_baseband_filter_bw (bandwidth_hz : Interfaces.Unsigned_32) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:1738
   with Import => True,
        Convention => C,
        External_Name => "hackrf_compute_baseband_filter_bw";

   function hackrf_set_hw_sync_mode (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1754
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_hw_sync_mode";

   function hackrf_init_sweep
     (device : access hackrf_device;
      frequency_list : access Interfaces.Unsigned_16;
      num_ranges : int;
      num_bytes : Interfaces.Unsigned_32;
      step_width : Interfaces.Unsigned_32;
      offset : Interfaces.Unsigned_32;
      style : sweep_style) return int  -- /usr/local/include/libhackrf/hackrf.h:1774
   with Import => True,
        Convention => C,
        External_Name => "hackrf_init_sweep";

   function hackrf_get_operacake_boards (device : access hackrf_device; boards : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1794
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_operacake_boards";

   function hackrf_set_operacake_mode
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      mode : operacake_switching_mode) return int  -- /usr/local/include/libhackrf/hackrf.h:1808
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_mode";

   function hackrf_get_operacake_mode
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      mode : access operacake_switching_mode) return int  -- /usr/local/include/libhackrf/hackrf.h:1823
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_operacake_mode";

   function hackrf_set_operacake_ports
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      port_a : Interfaces.Unsigned_8;
      port_b : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1841
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_ports";

   function hackrf_set_operacake_dwell_times
     (device : access hackrf_device;
      dwell_times : access hackrf_operacake_dwell_time;
      count : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1861
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_dwell_times";

   function hackrf_set_operacake_freq_ranges
     (device : access hackrf_device;
      freq_ranges : access hackrf_operacake_freq_range;
      count : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1880
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_freq_ranges";

   function hackrf_reset (device : access hackrf_device) return int  -- /usr/local/include/libhackrf/hackrf.h:1893
   with Import => True,
        Convention => C,
        External_Name => "hackrf_reset";

   function hackrf_set_operacake_ranges
     (device : access hackrf_device;
      ranges : access Interfaces.Unsigned_8;
      num_ranges : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1910
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_operacake_ranges";

   function hackrf_set_clkout_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1924
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_clkout_enable";

   function hackrf_get_clkin_status (device : access hackrf_device; status : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1939
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_clkin_status";

   function hackrf_operacake_gpio_test
     (device : access hackrf_device;
      address : Interfaces.Unsigned_8;
      test_result : access Interfaces.Unsigned_16) return int  -- /usr/local/include/libhackrf/hackrf.h:1956
   with Import => True,
        Convention => C,
        External_Name => "hackrf_operacake_gpio_test";

   function hackrf_set_ui_enable (device : access hackrf_device; value : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:1987
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_ui_enable";

   function hackrf_start_rx_sweep
     (device : access hackrf_device;
      callback : hackrf_sample_block_cb_fn;
      rx_ctx : System.Address) return int  -- /usr/local/include/libhackrf/hackrf.h:2001
   with Import => True,
        Convention => C,
        External_Name => "hackrf_start_rx_sweep";

   function hackrf_get_transfer_buffer_size (device : access hackrf_device) return Interfaces.C.size_t  -- /usr/local/include/libhackrf/hackrf.h:2013
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_transfer_buffer_size";

   function hackrf_get_transfer_queue_depth (device : access hackrf_device) return Interfaces.Unsigned_32  -- /usr/local/include/libhackrf/hackrf.h:2022
   with Import => True,
        Convention => C,
        External_Name => "hackrf_get_transfer_queue_depth";

   function hackrf_board_rev_read (device : access hackrf_device; value : access Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:2033
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_rev_read";

   function hackrf_board_rev_name (board_rev : hackrf_board_rev) return Interfaces.C.Strings.chars_ptr  -- /usr/local/include/libhackrf/hackrf.h:2042
   with Import => True,
        Convention => C,
        External_Name => "hackrf_board_rev_name";

   function hackrf_supported_platform_read (device : access hackrf_device; value : access Interfaces.Unsigned_32) return int  -- /usr/local/include/libhackrf/hackrf.h:2055
   with Import => True,
        Convention => C,
        External_Name => "hackrf_supported_platform_read";

   function hackrf_set_leds (device : access hackrf_device; state : Interfaces.Unsigned_8) return int  -- /usr/local/include/libhackrf/hackrf.h:2073
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_leds";

   function hackrf_set_user_bias_t_opts (device : access hackrf_device; req : access hackrf_bias_t_user_settting_req) return int  -- /usr/local/include/libhackrf/hackrf.h:2099
   with Import => True,
        Convention => C,
        External_Name => "hackrf_set_user_bias_t_opts";

end libhackrf;

pragma Style_Checks (On);
pragma Warnings (On, "-gnatwu");
