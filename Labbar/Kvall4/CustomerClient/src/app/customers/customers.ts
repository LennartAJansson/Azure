import { Component, inject, signal } from '@angular/core';
import { CustomerService, Customer } from '../core/customer.service';

@Component({
  selector: 'app-customers',
  templateUrl: './customers.html',
  styleUrl: './customers.css',
})
export class Customers {
  private readonly api = inject(CustomerService);

  protected readonly customers = signal<Customer[]>([]);
  protected readonly loading = signal(false);
  protected readonly error = signal<string | null>(null);
  protected readonly name = signal('');
  protected readonly email = signal('');
  protected readonly city = signal('');

  constructor() {
    this.reload();
  }

  protected reload(): void {
    this.loading.set(true);
    this.error.set(null);
    this.api.list().subscribe({
      next: (list) => {
        this.customers.set(list);
        this.loading.set(false);
      },
      error: (err) => this.fail(err),
    });
  }

  protected add(): void {
    const name = this.name().trim();
    if (!name) return;
    const email = this.email().trim() || undefined;
    const city = this.city().trim() || undefined;
    this.api.create({ name, email, city }).subscribe({
      next: () => {
        this.name.set('');
        this.email.set('');
        this.city.set('');
        this.reload();
      },
      error: (err) => this.fail(err),
    });
  }

  protected remove(c: Customer): void {
    this.api.remove(c.id).subscribe({
      next: () => this.reload(),
      error: (err) => this.fail(err),
    });
  }

  private fail(err: { status?: number; message?: string }): void {
    this.loading.set(false);
    this.error.set(
      err.status === 0
        ? 'Kunde inte nå API:t. Kontrollera adressen i config.json och CORS-inställningen.'
        : `Fel från API:t (${err.status ?? '?'}): ${err.message ?? ''}`,
    );
  }
}
