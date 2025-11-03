// app/javascript/controllers/debounced_submit_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 600 },
    min: { type: Number, default: 3 }
  };

  connect() {
    this._timer = null;
    this._isComposing = false;
  }

  input(event) {
    if (this._isComposing) return; // defer while IME composing
    const form = this.element;
    const target = event?.target;

    // Only submit text input when length is 0 (clear) or >= min
    if (target && target.name === "q") {
      const value = (target.value || "").trim();
      if (value.length === 0 || value.length >= this.minValue) {
        this.queueSubmit(form);
      }
      return;
    }

    // For non-text controls (e.g., selects), submit immediately (debounced)
    this.queueSubmit(form);
  }

  // IME composition handling for smoother typing
  compositionstart() { this._isComposing = true; }
  compositionend(e) {
    this._isComposing = false;
    // Trigger one final input handling with the completed text
    this.input(e || {});
  }

  queueSubmit(form) {
    if (this._timer) clearTimeout(this._timer);
    this._timer = setTimeout(() => {
      if (typeof form.requestSubmit === "function") {
        form.requestSubmit();
      } else {
        form.submit();
      }
    }, this.delayValue);
  }
}


