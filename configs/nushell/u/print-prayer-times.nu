# Ref: https://aladhan.com/prayer-times-api
export def main [
	...coordinates: number
	--no-cache (-n)
	--verbose (-v)
]: nothing -> nothing {
    mut $coordinates = $coordinates
	let $method = 20 # KEMENAG
	let $la = 2 # Angle Based
	let $tune = {
		Imsak: 0
		Fajr: 2
		Sunrise: 0
		Dhuhr: 3
		Asr: 3
		Maghrib: 3
		Sunset: 0
		Isha: 2
		Midnight: 0
	}
    if ($coordinates | is-empty) {
        $coordinates = [-6.5897 107.5397]
    }
    let $date = (date now | format date %d-%m-%Y)
    let $cache = $"($nu.temp-dir)/nu-prayertimes-($date).nuon"
    let $res = (match ((not $no_cache) and ($cache | path exists)) {
        false => {
			let $url = ([
				https://api.aladhan.com/v1/timings/
				$date
				?latitude=
				$coordinates.0
				&longitude=
				$coordinates.1
				&latitudeAdjustmentMethod=
				$la
				&method=
				$method
				&tune=
				($tune | values | str join ",")
			] | str join)
			if ($verbose) {print $url}
            let $data = (http get $url)
            $data | to nuon | save -f $cache
            print "CIMAHI UTARA"
            $data 
        }
        true => {
            print "CIMAHI UTARA (cached)"
            open $cache
        }
    })
    # alt: https://islamicfinder.us/index.php/api/prayer_times?latitude=-6.8597&longitude=107.5397&timezone=Asia/Jakarta&time_format=0&zipcode=40511
    if $res.status == "OK" {
        print ($res.data.date.gregorian.date)
        print ($res.data.timings | select Fajr Dhuhr Asr Maghrib Isha)
    } else {
        print "Something’s wrong." $res
    }
}
