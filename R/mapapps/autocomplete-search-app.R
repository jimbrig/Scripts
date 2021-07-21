library(shiny)
library(googleway)

config <- config::get()
key <- config$gcp$gmaps_api_key
set_key(key = key)

ui <- shiny::basicPage(

  div(
    textInput(inputId = "my_address", label = "Type An Address")
    ,textOutput(outputId = "full_address")
    ,HTML(paste0(" <script>
                function initAutocomplete() {

                 var autocomplete =   new google.maps.places.Autocomplete(document.getElementById('my_address'),{types: ['geocode']});
                 autocomplete.setFields(['address_components', 'formatted_address',  'geometry', 'icon', 'name']);
                 autocomplete.addListener('place_changed', function() {
                 var place = autocomplete.getPlace();
                 if (!place.geometry) {
                 return;
                 }

                 var addressPretty = place.formatted_address;
                 var address = '';
                 if (place.address_components) {
                 address = [
                 (place.address_components[0] && place.address_components[0].short_name || ''),
                 (place.address_components[1] && place.address_components[1].short_name || ''),
                 (place.address_components[2] && place.address_components[2].short_name || ''),
                 (place.address_components[3] && place.address_components[3].short_name || ''),
                 (place.address_components[4] && place.address_components[4].short_name || ''),
                 (place.address_components[5] && place.address_components[5].short_name || ''),
                 (place.address_components[6] && place.address_components[6].short_name || ''),
                 (place.address_components[7] && place.address_components[7].short_name || '')
                 ].join(' ');
                 }
                 var address_number =''
                 address_number = [(place.address_components[0] && place.address_components[0].short_name || '')]
                 var coords = place.geometry.location;
                 //console.log(address);
                 Shiny.onInputChange('jsValue', address);
                 Shiny.onInputChange('jsValueAddressNumber', address_number);
                 Shiny.onInputChange('jsValuePretty', addressPretty);
                 Shiny.onInputChange('jsValueCoords', coords);});}
                 </script>
                 <script src='https://maps.googleapis.com/maps/api/js?key=", key,"&libraries=places&callback=initAutocomplete' async defer></script>"))
    ,google_mapOutput(outputId = "my_map")
  )

)

server <- function(input, output) {

  my_address <- reactive({
    if(!is.null(input$jsValueAddressNumber)){
      if(length(grep(pattern = input$jsValueAddressNumber, x = input$jsValuePretty ))==0){
        final_address<- c(input$jsValueAddressNumber, input$jsValuePretty)
      } else{
        final_address<- input$jsValuePretty
      }
      final_address
    }
  })


  output$full_address <- renderText({
    if(!is.null(my_address())){
      my_address()
    }
  })

  output$my_map <- renderGoogle_map({
    my_address <- my_address()
    shiny::validate(
      need(my_address, "Address not available")
    )

    not_a_df <- google_geocode(address = my_address)
    my_coords <- geocode_coordinates(not_a_df)
    my_coords <- c(my_coords$lat[1], my_coords$lng[1])

    google_map(
      location = my_coords,
      zoom = 12,
      map_type_control = FALSE,
      zoom_control = FALSE,
      street_view_control = FALSE
    )
  })

}

shinyApp(ui, server)
