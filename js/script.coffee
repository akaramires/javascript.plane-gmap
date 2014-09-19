class Map
  mapOptions = {};
  locations = {};
  markers = [];

  interval = null;

  directionsDisplay = null;
  directionsService = null;
  map = null;
  geocoder = null;
  line = null;
  bounds = null;
  interval = null;

  constructor: ->
    @setMapOptions()
    @initMap()
    @assignBoxEvents()

  assignBoxEvents: ->
    self = @
    $(document).on('click', '#findBtn', =>
      self.find()
    )

  clearRoute: ->
    @setProgress(0)
    $(".progressBar").hide();

    if typeof @markers != 'undefined' and @markers.length > 0
      for i in [0...@markers.length]
        @markers[i].setMap null

      @markers = [];

    if typeof @line != 'undefined' and @line != null
      clearInterval @interval
      @line.set('icons', null)
      @line.setMap null

    @locations = {};

  initMap: =>
    $('.mapContainer #map').css('height', ($(window).height() - 54) + 'px');

    @directionsService = new google.maps.DirectionsService();
    @directionsDisplay = new google.maps.DirectionsRenderer();

    if typeof @map is 'undefined'
      @map = new google.maps.Map(document.getElementById('map'), @mapOptions);
      @directionsDisplay.setMap(@map);

    @geocoder = new google.maps.Geocoder();

  setMapOptions: =>
    @mapOptions =
      zoom: 4,
      center: new google.maps.LatLng(43.8476, 71.3564),
      mapTypeId: google.maps.MapTypeId.ROADMAP,
      panControl: false,
      zoomControl: false,
      disableDoubleClickZoom: true,
      mapTypeControl: false,
      scaleControl: false,
      streetViewControl: false,
      overviewMapControl: false,
      styles: [
        {
          featureType: "water",
          elementType: "geometry",
          stylers: [
            {color: "#245f89"},
            {visibility: "on"}
          ]
        },
        {
          featureType: "water", elementType: "labels.text",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "landscape", elementType: "geometry",
          stylers: [
            {color: "#3b7da4"},
            {visibility: "on"}
          ]
        },
        {
          featureType: "administrative.country",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "administrative.province",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "administrative.neighborhood",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "administrative.land_parcel",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "road",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "poi",
          stylers: [
            {visibility: "off"}
          ]
        },
        {
          featureType: "transit",
          stylers: [
            {visibility: "off"}
          ]
        }
      ]

  find: =>
    @clearRoute()

    $(".progressBar").show()

    $start = document.getElementById('start_location')
    $end = document.getElementById('end_location')

    @locations =
      start: $start.value
      end: $end.value

    @initMap()
    @geocodeAddress(@locations.start, true)

  geocodeAddress: (location, isStart)=>
    self = @
    @geocoder.geocode(
      'address': location,
      (results, status) =>
        if status == google.maps.GeocoderStatus.OK
          self.map.setCenter(results[0].geometry.location)

          self.createMarker(results[0].geometry.location, location[0] + "<br>" + location[1]);

          if isStart
            self.geocodeAddress(self.locations.end, false)
        else
          console.error("some problem in geocode" + status)
    )

  createMarker: (latlng, html) =>
    marker = new google.maps.Marker({
      position: latlng
      map: map,
      icon:
        path: google.maps.SymbolPath.CIRCLE,
        scale: 4,
        strokeColor: '#FFFF00',
        strokeOpacity: 1,
        strokeWeight: 2,
        fillColor: '#FFFF00',
        fillOpacity: 1
    })

    if typeof @markers is 'undefined'
      @markers = []

    @markers.push marker

    if @markers? && @markers.length == 2
      @setCenter()
      @drawLine()


  setCenter: =>
    @bounds = new google.maps.LatLngBounds()
    @bounds.extend(@markers[0].getPosition())
    @bounds.extend(@markers[1].getPosition())
    @map.fitBounds(@bounds)

  drawLine: =>
    self = @

    iconTypes =
      airplane:
        path: "M 0,-24 3,-22 3,-10 21,6 21,12 3,2 3,15 9,19 9,24 -1,22 0,24 1,22 -9,24 -9,19 -3,15 -3,2 -21,12 -21,6 -3,-10 -3,-22 0,-24 z",
        fillColor: "#fffc01",
        fillOpacity: 1,
        scale: 0.7,
        strokeColor: "#3b7da4",
        strokeWeight: 2,
        strokeOpacity: 0.8
      train:
        path: "m-9.307024,2.134448c-0.699999,1.1 -3,2.4 -5.099998,3.1c-2,0.7 -4.200001,2.1 -4.700001,3.099999c-0.6,1.09999 -1,11 -1,23.1c0,18.800003 0.199999,21.5 1.799999,23.200001c1.6,1.900002 1.6,2 -0.6,3.400002c-1.199999,0.899998 -2.199999,2.599998 -2.199999,3.899998c0,3.499992 3.5,3.099991 8.6,-1.099998c4.1,-3.400002 4.6,-3.5 12.4,-3.5c7.799999,0 8.299999,0.099998 12.400001,3.5c5.099998,4.199989 8.599998,4.599991 8.599998,1.099998c0,-1.299999 -1,-3 -2.200001,-3.899998c-2.200001,-1.400002 -2.200001,-1.5 -0.5,-3.400002c1.5,-1.700001 1.700001,-4.399998 1.700001,-23.200001c0,-12.1 -0.400002,-22 -1,-23.1c-0.5,-1 -2.700001,-2.4 -4.700001,-3.099999c-2.099998,-0.7 -4.399998,-2 -5.099998,-3.1c-1.7,-2.4 -4.900001,-2.3 -6.200001,0.2c-0.599998,1.1 -1.900001,2 -3,2c-1.1,0 -2.4,-0.9 -3,-2c-1.299999,-2.5 -4.5,-2.60001 -6.200001,-0.2zm15.5,6.9c1.600002,1.5 -1.799999,3.3 -6.299999,3.3c-4.5,0 -7.9,-1.8 -6.299999,-3.3c0.799999,-0.9 11.799999,-0.9 12.599998,0zm6.5,7.200002c0.900002,0.499998 1.200001,2.6 1,6.699999l-0.299999,5.900002l-13.5,0l-13.5,0l-0.299999,-5.900002c-0.200001,-4.099998 0.099998,-6.200001 1,-6.699999c1.699999,-1.100001 23.899998,-1.100001 25.599998,0zm-21.299999,32.1c0,1.799999 -0.6,2.599998 -2.299999,2.799999c-2.400002,0.400002 -3.800001,-1.799999 -2.800001,-4.399998c0.300001,-0.900002 1.5,-1.400002 2.800001,-1.200001c1.699999,0.200001 2.299999,1 2.299999,2.799999zm22,0c0,1.799999 -0.599998,2.599998 -2.299999,2.799999c-2.400002,0.400002 -3.799999,-1.799999 -2.799999,-4.399998c0.299999,-0.900002 1.5,-1.400002 2.799999,-1.200001c1.700001,0.200001 2.299999,1 2.299999,2.799999z",
        fillColor: "#fffc01",
        fillOpacity: 1,
        scale: 0.4,
        strokeColor: "#3b7da4",
        strokeWeight: 2,
        strokeOpacity: 0.8

    $iconTypeInput = document.getElementById('iconType')

    self.line = new google.maps.Polyline({
      path: [
        self.markers[0].getPosition(),
        self.markers[1].getPosition()
      ],
      icons: [
        {
          icon: iconTypes[$iconTypeInput.value],
          fixedRotation: !($iconTypeInput.dataset.fixedRotation == 'false'),
          offset: '100%'
        }
      ],
      strokeColor: "#FFFF00",
      strokeOpacity: 1.0,
      strokeWeight: 2,
      map: self.map
    });
    @fly()

  fly: =>
    self = @
    speed = 8
    count = 0
    @interval = setInterval () ->
      count = (count + 1) % (speed * 100)
      #      if (count > (speed * 100 - 2))
      #        clearInterval(self.interval)
      #        self.line.set('icons', null)
      #        $(".progressBar").hide()

      if (self.line != null)
        icons = self.line.get('icons');

        if (icons != null)
          icons[0].offset = (count / speed) + '%'
          self.line.set('icons', icons)

      if (!(count % 50))
        self.setProgress((count / speed))
    , (speed * 3)

  setProgress: (state) =>
    $(".progressBar #_runner").css('width', state + '%').data('index', state);

window.Map = new Map;