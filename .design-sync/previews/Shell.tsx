import React from "react";
import {
	Shell, Title, MeanderRule, Chronicle, SeasonHeading, Entry, Colophon,
	Panel, PanelHeading, StatusStrip, Refusal, Button, ButtonRow, Stack,
	Stepper, Stats, Stat,
} from "@tin-road/design-system";

export const TheBookAndTheTool = () => (
	<Shell
		book={
			<>
				<Title>THE TIN ROAD</Title>
				<MeanderRule />
				<Chronicle>
					<Colophon>Seed 101. Written as it happens.</Colophon>
					<SeasonHeading>The First Season</SeasonHeading>
					<Entry>In the first season of House Sapanu, Gamiradu took up the pen.</Entry>
					<Entry>
						The water at the Salt Marsh took its census: 4 sheets of papyrus
						came out pulp. The clay came out streaked but legible.
					</Entry>
				</Chronicle>
			</>
		}
		aside={
			<Stack>
				<StatusStrip>
					Gamiradu at the Salt Marsh — day 4 — 31 light — 2 clay, 2 papyrus,
					2 seals — purse 2 — next step 2 light
				</StatusStrip>
				<Panel major>
					<PanelHeading>The road</PanelHeading>
					<Stack>
						<Button tone="primary">Travel to the next node</Button>
						<ButtonRow>
							<Button>Note</Button>
							<Button>Record</Button>
							<Button>Survey</Button>
							<Button>Treatise</Button>
						</ButtonRow>
						<Button tone="danger">Send the ledger home by courier</Button>
					</Stack>
					<Refusal>
						No courier goes: it takes a seal, 4 media, and something written.
					</Refusal>
				</Panel>
			</Stack>
		}
	/>
);

export const TheOutfitDesk = () => (
	<Shell
		book={
			<Chronicle>
				<SeasonHeading>The Eighth Season</SeasonHeading>
				<Entry>
					While the House slept, a caravan walked the Ugarit road on its own
					and came home with 362 shekels, weighed. The drovers took their 60
					at the gate. The road remembered; it had been written down.
				</Entry>
				<Entry>
					The season began as seasons do: House Yabninu's silver on the table,
					30 shekels of it, and the understanding that backing Ibiranu would
					continue exactly as long as it paid.
				</Entry>
			</Chronicle>
		}
		aside={
			<Panel>
				<PanelHeading>Outfit the season</PanelHeading>
				<Stack>
					<Stepper label="Clay" hint="cheap, heavy, survives water"
						value={2} onChange={() => {}} />
					<Stepper label="Papyrus" hint="light, ruined by water"
						value={6} onChange={() => {}} />
					<Stepper label="Seals" hint="authenticate, or pay the courier"
						value={2} onChange={() => {}} />
					<Stats>
						<Stat label="cost" value="24 shekels" />
						<Stat label="bulk" value="12 of 16" />
						<Stat label="treasury" value="0 + 30 advance" />
					</Stats>
					<Button tone="primary">Buy the pack and take the road</Button>
				</Stack>
			</Panel>
		}
	/>
);
