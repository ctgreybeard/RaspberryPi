#!perl

# SVN Id $Id: 015-device.t 1028 2013-03-11 16:04:27Z Mark Dootson $

use Test::More tests => 5;

BEGIN {
    use_ok( 'HiPi::Device::GPIO' );
    use_ok( 'HiPi::Device::I2C' );
    use_ok( 'HiPi::Device::OneWire' );
    use_ok( 'HiPi::Device::SerialPort' );
    use_ok( 'HiPi::Device::SPI' );
}

1;
