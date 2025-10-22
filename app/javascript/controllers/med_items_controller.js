// app/javascript/controllers/med_items_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["container"];

    add(e) {
        e.preventDefault();
        const template = document.querySelector(e.params.template);
        if (!template) return;
        const key = Date.now().toString();
        const html = template.innerHTML.replaceAll("NEW_KEY", key);
        const wrapper = document.createElement("div");
        wrapper.innerHTML = html.trim();
        this.containerTarget.appendChild(wrapper.firstElementChild);
    }

    remove(e) {
        e.preventDefault();
        e.target.closest("[data-med-items-row]")?.remove();
    }

    select(e) {
        const row = e.target.closest("[data-med-items-row]");
        const cents = parseInt(e.target.selectedOptions?.[0]?.dataset.price || "0", 10);
        row?.querySelector('input[data-role="unit-price-cents"]')?.setAttribute("value", cents);
        const label = row?.querySelector('[data-role="unit-price-text"]');
        if (label) label.textContent = new Intl.NumberFormat(undefined, { style: "currency", currency: "USD" }).format((cents || 0) / 100);
    }
}