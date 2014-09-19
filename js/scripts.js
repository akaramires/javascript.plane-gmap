var locations = {};

var directionsDisplay,
    directionsService,
    map,
    geocoder,
    markers = [],
    line,
    bounds,
    interval;

initialize();

function find() {
    clearMarkers();

    $(".progressBar").show();

    var $start = document.getElementById('start_location');
    var $end = document.getElementById('end_location');

    locations.start = $start.value;
    locations.end = $end.value;

    initialize();
    geocodeAddress(locations.start, true);
}

function clearMarkers() {
    if (markers.length) {
        for (var i = 0; i < markers.length; i++) {
            markers[i].setMap(null);
        }
        markers = [];
    }

    if (line != null) {
        clearInterval(interval);
        line.set('icons', null);
        line.setMap(null);
    }

    locations = {};
    $(".progressBar").hide();
}

function initialize() {
    $('.mapContainer #map').css('height', ($(window).height() - 54) + 'px');
    directionsService = new google.maps.DirectionsService();
    directionsDisplay = new google.maps.DirectionsRenderer();

    var mapOptions = {
        zoom                  : 4,
        center                : new google.maps.LatLng(43.8476, 71.3564),
        mapTypeId             : google.maps.MapTypeId.ROADMAP,
        panControl            : false,
        zoomControl           : false,
        disableDoubleClickZoom: true,
        mapTypeControl        : false,
        scaleControl          : false,
        streetViewControl     : false,
        overviewMapControl    : false,
        styles                : [
            {featureType   : "water",
                elementType: "geometry", stylers: [
                {color: "#245f89"},
                {visibility: "on"}
            ]},
            {featureType: "water", elementType: "labels.text", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "landscape", elementType: "geometry", stylers: [
                {color: "#3b7da4"},
                {visibility: "on"}
            ]},
            {featureType: "administrative.country", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "administrative.province", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "administrative.neighborhood", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "administrative.land_parcel", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "road", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "poi", stylers: [
                {visibility: "off"}
            ]},
            {featureType: "transit", stylers: [
                {visibility: "off"}
            ]}
        ]
    };

    if (map == undefined) {
        map = new google.maps.Map(document.getElementById('map'), mapOptions);
        directionsDisplay.setMap(map);
    }

    geocoder = new google.maps.Geocoder();
}

function geocodeAddress(location, isStart) {
    geocoder.geocode({ 'address': location}, function (results, status) {
        if (status == google.maps.GeocoderStatus.OK) {

            map.setCenter(results[0].geometry.location);
            createMarker(results[0].geometry.location, location[0] + "<br>" + location[1]);

            if (isStart) {
                geocodeAddress(locations.end, false);
            }
        }
        else {
            console.error("some problem in geocode" + status);
        }
    });
}

function createMarker(latlng, html) {
    var marker = new google.maps.Marker({
        position: latlng,
        map     : map,
        icon    : {
            path         : google.maps.SymbolPath.CIRCLE,
            scale        : 4,
            strokeColor  : '#FFFF00',
            strokeOpacity: 1,
            strokeWeight : 2,
            fillColor    : '#FFFF00',
            fillOpacity  : 1
        }
    });
    markers.push(marker);

    if (markers.length == 2) {
        setCenter();
    }
}

function setCenter() {
    bounds = new google.maps.LatLngBounds();
    bounds.extend(markers[0].getPosition());
    bounds.extend(markers[1].getPosition());
    map.fitBounds(bounds);

//    drawRoute(locations[0], locations[1]);
    drawLine();
}

function drawRoute(start, end) {
    var request = {
        origin     : start,
        destination: end,
        travelMode : google.maps.TravelMode.DRIVING
    };
    directionsService.route(request, function (result, status) {
        if (status == google.maps.DirectionsStatus.OK) {
            directionsDisplay.setDirections(result);
        }
    });
}

function drawLine() {
    var airplane = {
        path         : "M 0,-24 3,-22 3,-10 21,6 21,12 3,2 3,15 9,19 9,24 -1,22 0,24 1,22 -9,24 -9,19 -3,15 -3,2 -21,12 -21,6 -3,-10 -3,-22 0,-24 z",
        fillColor    : "#fffc01",
        fillOpacity  : 1,
        scale        : 0.7,
        strokeColor  : "#3b7da4",
        strokeWeight : 2,
        strokeOpacity: 0.8
    };

    line = new google.maps.Polyline({
        path         : [
            markers[0].getPosition(),
            markers[1].getPosition()
        ],
        icons        : [
            {
                icon  : airplane,
                offset: '100%'
            }
        ],
        strokeColor  : "#FFFF00",
        strokeOpacity: 1.0,
        strokeWeight : 2,
        map          : map
    });

    animate();
}

function animate() {
    var speed = 8;
    var count = 0;
    interval = window.setInterval(function () {
        count = (count + 1) % (speed * 100);

        if (count == (speed * 100 - 1)) {
            clearInterval(interval);
            line.set('icons', null);
            $(".progressBar").hide();
        }

        if (line != null) {
            var icons = line.get('icons');
            if (icons != null) {
                icons[0].offset = (count / speed) + '%';
                line.set('icons', icons);
            }
        }
        if (!(count % 50)) {
            setProgress(count / speed);
        }
    }, speed * 3);
}


function setProgress(state) {
    $(".progressBar #_runner").css('width', state + '%').data('index', state);
}