import { useBackend } from '../backend';
import { Button, Knob, ProgressBar, Box, Section } from '../components';
import { Window } from '../layouts';
import { createLogger } from '../logging';
export const EngineControlConsole = (_props, context) => {
  const { act, data } = useBackend(context);
  const logger = createLogger('Debug');
  logger.warn(data);
  return (
    <Window width={455} height={275}>
      <Window.Content scrollable>
        <Section title="Engine Temperature">
          <Box textAlign="center">
            <ProgressBar
              width="180%"
              minValue={0}
              maxValue={180}
              value={data.temp}
              ranges={{
                good: [-Infinity, 50],
                bad: [100, Infinity],
              }}>
              <Box textAlign="center">{data.temp}% to overheat</Box>
            </ProgressBar>
          </Box>
        </Section>
        <Section title="Engine Efficiency">
          <Box textAlign="center">
            <ProgressBar
              width="100%"
              minValue={0}
              maxValue={2}
              value={data.EngineEfficiency}
              ranges={{
                good: [Infinity, 1],
                bad: [0.9, -Infinity],
              }}>
              <Box textAlign="center">
                {data.EngineEfficiency} Engine Efficiency Modifier
              </Box>
            </ProgressBar>
          </Box>
        </Section>
        <Section title="Engine Control">
          {
            <Knob
              inline
              animated={false}
              maxValue={200}
              minValue={0}
              value={data.freq1g}
              onChange={(e, value) => act('p_freq', { 'freq1g': value })}
              stepPixelSize={1}
            />
          }
          {
            <Knob
              inline
              animated={false}
              maxValue={200}
              minValue={0}
              value={data.freq1g}
              onChange={(e, value) => act('s_freq', { 'freq2g': value })}
              stepPixelSize={1}
            />
          }
          {
            <Button
              fontSize="20px"
              textAlign="center"
              fluid
              disabled={data.alt === 0.5}
              content="Calculate Frequency Deviation"
              iconPosition="right"
              onClick={() => act('calculate')}
            />
          }
        </Section>
      </Window.Content>
    </Window>
  );
};
