import { Controller } from "@hotwired/stimulus" // Stimulus is a JS framework https://stimulus.hotwired.dev/. 

export default class extends Controller {
    static targets = ["select", "fields", "nameField"] //Defines the targets for the controller. A target is an element that the controller will manage.

    connect() { //Connect is a method that is called when the controller is connected to the element.
        this.toggleFields() //This is a method that is called when the controller is connected to the element.
    }

    toggleFields() {
        if (this.selectTarget.value === 'new') { // If the value of the select element is 'new', then the fields element will be displayed.
            this.fieldsTarget.style.display = 'block' //We use this to reference the fields target (notice that they are static).
            this.nameFieldTarget.required = true;
        } else {
            this.fieldsTarget.style.display = 'none'
            this.nameFieldTarget.required = false;
        }
    }
} 