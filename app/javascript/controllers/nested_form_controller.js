import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["container"];

    add(event) {
        event.preventDefault();
        const templateSelector = event.params.template;
        const template = document.querySelector(templateSelector);
        if (!template) return;

        const html = template.innerHTML.replaceAll("NEW_RECORD", Date.now().toString());
        const wrapper = document.createElement("div");
        wrapper.innerHTML = html;
        this.containerTarget.appendChild(wrapper.firstElementChild);
    }

    remove(event) {
        event.preventDefault();
        const row = event.target.closest(".flex.items-center");
        if (row) row.remove();
    }
}