library(shiny)
library(googleway)
library(shinydashboard)

config <- config::get()
key <- config$gcp$gmaps_api_key
set_key(key = key)


ui<- shinydashboard::dashboardPage(
  dashboardHeader(title = "This Works"),
  dashboardSidebar(shinydashboard::sidebarMenu(id="sideBar_Menu",
                                               menuItem("Data Import", tabName="datatab", icon = icon("database")),
                                               conditionalPanel("input.sideBar_Menu=='datatab'",
                                                                shiny::radioButtons(inputId = "upload_custom_data", label = "Do You Want To Upload Your Own Data?", choices  = c("Yes"=TRUE, "No"=FALSE), selected = TRUE, inline = TRUE),

                                                                conditionalPanel("input.upload_custom_data == 'TRUE'",
                                                                                 shiny::actionButton("go", "Go")),

                                                                conditionalPanel("input.upload_custom_data == 'FALSE'",
                                                                                 textInput(inputId = "my_address", label = "Type An Address"),
                                                                                 shiny::actionButton(inputId = "add_btn", label = "Add To Dataset", icon = icon("plus")))


                                               ), # with outer conditional menu
                                               menuItem("AnotherMenu", tabName = "anotherMenu", icon = icon("list-ol"))
  ) # with sidebar menu
  ),

  dashboardBody(
    HTML(paste0(" <script>
                function initAutocomplete() {

                var autocomplete = new google.maps.places.Autocomplete(document.getElementById('my_address'),{types: ['geocode']});
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
    ,uiOutput("tabContentUI")
  )
)



server <- function(input, output) {




  ### Output$Stuff Here
  output$anotherMenu_content<- shiny::renderText({"This is some text" })
  output$datatab_content<- shiny::renderUI({ list(shiny::uiOutput("full_address"), shiny::uiOutput("my_map")) })

  #### Tab Content UI Materials
  output$tabContentUI<- shiny::renderUI({
    shinydashboard::tabItems(
      shinydashboard::tabItem(tabName = "datatab", shiny::uiOutput("datatab_content")),
      shinydashboard::tabItem(tabName = "anotherMenu", shiny::textOutput("anotherMenu_content"))
    )
  })

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
      paste0("The Fuller and Fixed Address is... ", my_address())
    }
  })

  output$my_map <- renderGoogle_map({
    my_address <- my_address()
    shiny::validate(
      need(my_address, "Address not available")
    )

    gdat <- google_geocode(address = my_address)
    my_coords <- geocode_coordinates(gdat)
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
