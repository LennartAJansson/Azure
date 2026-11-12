import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { firstValueFrom } from 'rxjs';

export interface AppConfigData {
  apiBaseUrl: string;
}

/**
 * Runtime-konfiguration: samma bygge i alla miljöer.
 * config.json hämtas vid start och skrivs över av deploy-skriptet.
 */
@Injectable({ providedIn: 'root' })
export class AppConfig {
  private readonly http = inject(HttpClient);
  private readonly data = signal<AppConfigData>({ apiBaseUrl: '' });

  readonly apiBaseUrl = () => this.data().apiBaseUrl.replace(/\/+$/, '');

  async load(): Promise<void> {
    const cfg = await firstValueFrom(this.http.get<AppConfigData>('config.json'));
    this.data.set(cfg);
  }
}
