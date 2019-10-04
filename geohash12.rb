# License: see LICENSE file at root directory of `master` branch

##
# Geohash 32 utility. This class helps encode/decode to/from geohash 32 with 12 digits length.
#
# See: http://geohash.org
#
module Geohash12

    ##
    # Gem name.
    #
    GEM_NAME = 'Geohash12'

    ##
    # Gem version name.
    #
    GEM_VERSION_NAME = '4.1.1'

    ##
    # Gem release date.
    #
    GEM_RELEASE_DATE = Time.new(2017, 12, 3).freeze()

    ##
    # Base 32.
    #
    BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz'

    MIN_LATITUDE    = -90.0
    MAX_LATITUDE    = 90.0
    MIN_LONGITUDE   = -180.0
    MAX_LONGITUDE   = 180.0

    ##
    # Length of a geohash.
    #
    GEOHASH_LEN = 12

    ##
    # Number of bits of a "geobyte" (a single character of a geohash).
    #
    GEOBYTE_SIZE = 5

    ##
    # Number of bits of a geohash.
    #
    GEOHASH_BITS = GEOHASH_LEN * GEOBYTE_SIZE

    ##
    # Hi-index of bits of a geohash.
    #
    GEOHASH_BITS_HI = GEOHASH_BITS - 1

    ##
    # Max value of an integer geohash.
    #
    MAX_INT_GEOHASH = 1152921504606846975

    ##
    # Encodes latitude & longitude to an integer geohash.
    #
    # Note: this method runs some loops with total 60 times.
    #
    # Parameters:
    #
    # - `latitude`: latitude.
    # - `longitude`: longitude.
    # - `bits`: if provided, it will be set to geohash bits.
    #
    # Returns: integer geohash.
    #
    def self.encode_int(latitude, longitude, bits=nil)
        result = 0
        lo_hi = [[MIN_LONGITUDE, MAX_LONGITUDE], [MIN_LATITUDE, MAX_LATITUDE]]
        lon_lat = [longitude, latitude]

        # Even bits are longitude code, odd bits are latitude code
        # m is either index for longitude components, or latitude components
        # It starts from 0 -- which is index for longitude components
        m = 0
        bits.clear.insert 0, * [0] * GEOHASH_BITS if bits
        (GEOHASH_LEN / 2).times do |i|
            (GEOBYTE_SIZE * 2).times do |k|
                mid = (lo_hi[m][0] + lo_hi[m][1]) / 2.0
                if lon_lat[m] <= mid
                    lo_hi[m][1] = mid
                else
                    lo_hi[m][0] = mid

                    bit_index = i * GEOBYTE_SIZE * 2 + k
                    result |= 1 << (GEOHASH_BITS_HI - bit_index)
                    bits[bit_index] = 1 if bits
                end

                # Update index for latitude/longitude components
                m ^= 1
            end
        end

        result
    end # self.encode_int()

    ##
    # Encodes latitude & longitude to a string geohash.
    #
    # Note: this method runs some loops with total 120 times.
    #
    # Parameters:
    #
    # - `latitude`: latitude.
    # - `longitude`: longitude.
    #
    # Returns: geohash.
    #
    def self.encode(latitude, longitude)
        # Encode to bits
        bits = []
        encode_int latitude, longitude, bits

        # Now build the geohash string
        res = ''
        GEOHASH_LEN.times { |i|
            v = 0
            GEOBYTE_SIZE.times do |k|
                bit = bits[i * GEOBYTE_SIZE + k]
                next if bit == 0
                v += bit * (1 << (GEOBYTE_SIZE - k - 1))
            end

            res << BASE32[v]
        }

        res
    end # self.encode()

    ##
    # Decodes a geohash to latitude & longitude. Input can be a geohash or an integer geohash.
    #
    # Note: this method runs some loops with max 120 times.
    #
    # Parameters:
    #
    # - `geohash`: can be a geohash or an integer geohash.
    #
    # Returns: `[latitude, longitude]`.
    #
    def self.decode(geohash)
        bits = decode_to_bits(geohash)

        # Even bits are longitude code, odd bits are latitude code
        res = [0.0, 0.0]
        lo_hi = [[MIN_LATITUDE, MAX_LATITUDE], [MIN_LONGITUDE, MAX_LONGITUDE]]
        res.size.times { |i|
            k = i^1
            while k < bits.size do
                mid = (lo_hi[i][0] + lo_hi[i][1]) / 2.0
                if (bits[k] == 1)
                    lo_hi[i][0] = mid
                else
                    lo_hi[i][1] = mid
                end
                k += 2
            end

            res[i] = (lo_hi[i][0] + lo_hi[i][1]) / 2.0
        }

        res
    end # self.decode()

    ##
    # Decodes a geohash to bits. Input can be a geohash or an integer geohash.
    #
    # Note: this method runs some loops with max 60 times.
    #
    # Parameters:
    #
    # - `geohash`: can be a geohash or an integer geohash.
    #
    # Returns: geohash bits.
    #
    def self.decode_to_bits(geohash)
        if geohash.is_a?(String)
            bits = [0] * geohash.size * GEOBYTE_SIZE
            geohash.size.times { |i|
                v = BASE32.index geohash[i]
                count = GEOBYTE_SIZE
                while count > 0 do
                    bits[i * GEOBYTE_SIZE + (count -= 1)] = v % 2
                    v >>= 1
                end
            }

            return bits
        end # if geohash is string

        if geohash > MAX_INT_GEOHASH
            bits = [1] * GEOHASH_BITS
        else
            bits = geohash > 0 ? [] : [0] * GEOHASH_BITS
            while geohash > 0
                bits.insert 0, geohash % 2
                geohash >>= 1
            end

            # Note that the binary form might NOT have full length of GEOHASH_BITS.
            # So we insert missing bits here.
            bits.insert 0, * [0] * (GEOHASH_BITS - bits.size) if bits.size < GEOHASH_BITS
        end

        bits
    end # self.decode_to_bits()

end # Geohash12
