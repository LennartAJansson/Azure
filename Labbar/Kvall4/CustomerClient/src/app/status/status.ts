import { Component, inject, signal } from '@angular/core';
import { JsonPipe } from '@angular/common';
import { AppConfig } from '../core/app-config';
import { CustomerService } from '../core/customer.service';

@Component({
  selector: 'app-status',
  imports: [JsonPipe],
  templateUrl: './status.html',
})
export class Status {
  private readonly api = inject(CustomerService);
  protected readonly config = inject(AppConfig);

  protected readonly health = signal<string>('–');
  protected readonly who = signal<unknown>(null);

  protected check(): void {
    this.health.set('…');
    this.who.set(null);
    this.api.health().subscribe({
      next: (r) => this.health.set(`OK (${r})`),
      error: (e) => this.health.set(`Fel (${e.status ?? '?'})`),
    });
    this.api.whoami().subscribe({
      next: (r) => this.who.set(r),
      error: (e) => this.who.set({ fel: e.status ?? '?' }),
    });
  }
}
