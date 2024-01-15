package constants;
   // definition of led blinker in app - how fast and with what period
   // the blinking of the led_blinker triggers. 40MHz - we create
   // roughly 2.5second repetition with 100ms blinking
   parameter LED_BLINKER_PERIOD = 100e6;
   parameter LED_BLINKER_ON_TIME = 4.0e6;
   parameter LED_BLINKER_OFF_TIME = 4.0e6;
   // the same params for GEFE, but this time roughly 4 times slower
   // as gefe oscillator runs 25MHz (we cannot use engineering format
   // as microsemi synplify does not like it)
   parameter GEFE_LED_BLINKER_PERIOD = 400e6;
   parameter GEFE_LED_BLINKER_ON_TIME = 16000000;
   parameter GEFE_LED_BLINKER_OFF_TIME = 16000000;

   // definition of IRQ mco runner - how fast led diode blinks when
   // IRQ comes. 40MHz will generate 100ms blink signal:
   parameter LED_IRQ_MKO_BITS = 22;
   parameter LED_IRQ_MKO_VALUE = 22'(4000000);
   // parameters defining glitch catcher blinking, 100ms @40MHz
   parameter LED_GLICH_CATCHER_BITWIDTH = 22;
   parameter LED_GLICH_CATCHER_VALUE = (LED_GLICH_CATCHER_BITWIDTH)'(4000000);

   // this is pulse width of a single pulse going out to the stepper
   // motor. The value identifies NUMBER OF CLOCK CYCLES during whose
   // the pulse has to stay on '1'. The clock speed is 40MHz and
   // motor requires at least 1us as reliable pulse width, for sake of
   // security let's make 256 clocks, which is roughly 5+us per pulse
   parameter STEPPER_PULSE_WIDTH = 256;

   // following parameter is used in debounce module and identifies
   // how many clock cycles is needed to debounce. As this is
   // constant through the project, the constant is here. For the
   // synth we want debouncing of 5ms roughly. With 40MHz clock
   // this does roughly 10bits. That means, that when switch toggles,
   // it has to be for at least 5ms stable to 'claim' that switch
   // really switched.
   parameter g_DebouncingCounterWidth = 17;




endpackage // constants
